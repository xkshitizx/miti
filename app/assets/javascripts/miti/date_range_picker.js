import MitiConverter from "miti/converter"

const OPEN_CLASS = "miti-date-picker--open"

export default class MitiDateRangePicker {
  constructor(element) {
    this.element = element
    this.startInput = element.querySelector("[data-miti-range-target=start]")
    this.endInput = element.querySelector("[data-miti-range-target=end]")
    this.displayInput = element.querySelector(".miti-date-range__display")
    this.icon = element.querySelector(".miti-date-field__icon")
    this.theme = element.dataset.mitiTheme
    if (!this.theme) {
      const auto = element.closest("[data-miti-theme-auto]")
      if (!auto || auto.dataset.mitiThemeAuto !== "false") {
        if (window.matchMedia?.("(prefers-color-scheme: dark)").matches) {
          this.theme = "dark"
        }
      }
    }
    this.popover = null
    this.currentYear = null
    this.currentMonth = null
    this.view = "day"
    this.blurTimeout = null
    this.startDate = null
    this.endDate = null
    this._activeField = null
    this._listeners = []
    this._dragStart = null
    this._dragActive = false
    this._wasDragged = false
    this._dragRaf = null
  }

  attach() {
    if (this.element._mitiRangePicker) return
    this.element._mitiRangePicker = this
    if (this._attached) return
    this._attached = true
    MitiConverter.init()
    if (this.displayInput) {
      this._on(this.displayInput, "focus", (e) => this.open(e, "start"))
      this._on(this.displayInput, "blur", (e) => this.blur(e))
      this._on(this.displayInput, "keydown", (e) => this.keydown(e))
    }
    if (this.icon) this._on(this.icon, "click", (e) => this.open(e, "start"))
    this._parseDates()
    this._updateDisplayOnly()
  }

  destroy() {
    this.close()
    this._listeners.forEach(({ el, type, handler }) => el.removeEventListener(type, handler))
    this._listeners = []
    if (this.popover && this.popover.parentNode) {
      this.popover.parentNode.removeChild(this.popover)
    }
    this.popover = null
  }

  open(event, field) {
    this._activeField = field
    this._activeInput = this.displayInput || this.startInput
    if (!this._activeInput) return

    this._dragStart = null
    this._dragActive = false
    this._wasDragged = false

    if (event && event.type === "focus") {
      this._clearBlurTimeout()
    }

    if (this.popover) {
      this._parseDates()
      this._updateDisplayOnly()
      this.view = "day"
      this._renderPopoverContent()
      this.popover.style.display = "block"
      this._reposition()
      this.element.classList.add(OPEN_CLASS)
      return
    }

    this._parseDates()
    this._updateDisplayOnly()
    this.view = "day"
    this._buildPopover()
    this._reposition()
    document.body.appendChild(this.popover)
    this.element.classList.add(OPEN_CLASS)
    requestAnimationFrame(() => this._reposition())
  }

  close() {
    this._clearBlurTimeout()
    this._dragStart = null
    this._dragActive = false
    if (this._dragRaf) {
      cancelAnimationFrame(this._dragRaf)
      this._dragRaf = null
    }
    if (this.popover) {
      this.popover.style.display = "none"
    }
    this.element.classList.remove(OPEN_CLASS)
  }

  blur(event) {
    this.blurTimeout = setTimeout(() => {
      if (!this._isClickInsidePopover(event)) {
        this.close()
      }
    }, 200)
  }

  keydown(event) {
    switch (event.key) {
      case "Escape":
        if (this.view !== "day") {
          this.view = "day"
          this._renderPopoverContent()
        } else {
          this.close()
          ;(this.displayInput || this._activeInput)?.focus()
        }
        break
      case "Enter":
        event.preventDefault()
        this._selectFocusedDay()
        break
    }
  }

  _on(el, type, handler) {
    el.addEventListener(type, handler)
    this._listeners.push({ el, type, handler })
  }

  _buildPopover() {
    this.popover = document.createElement("div")
    this.popover.className = "miti-date-picker-popover"
    if (this.theme) this.popover.dataset.mitiTheme = this.theme

    this._on(this.popover, "mousedown", (e) => {
      this._clearBlurTimeout()
      const day = e.target.closest("[data-miti-day]")
      if (day) {
        e.preventDefault()
        this._startDrag(day)
      }
    })

    this._on(this.popover, "mouseover", (e) => {
      if (!this._dragStart) return
      const day = e.target.closest("[data-miti-day]")
      if (day) this._updateDrag(day)
    })

    this._on(document, "mouseup", (e) => this._endDrag(e))

    this._on(this.popover, "click", (e) => {
      this._clearBlurTimeout()

      const nav = e.target.closest("[data-miti-nav]")
      if (nav) {
        e.preventDefault()
        if (nav.dataset.mitiNav === "prev") this._navPrev()
        else if (nav.dataset.mitiNav === "next") this._navNext()
        return
      }

      const title = e.target.closest("[data-miti-title]")
      if (title) {
        if (this.view === "day") this.view = "month"
        else if (this.view === "month") this.view = "year"
        else this.view = "day"
        this._renderPopoverContent()
        return
      }

      const picker = e.target.closest("[data-miti-pick]")
      if (picker) {
        const val = parseInt(picker.dataset.mitiPick, 10)
        if (this.view === "month") {
          this.currentMonth = val
          this.view = "day"
        } else if (this.view === "year") {
          this.currentYear = val
          this.view = "month"
        }
        this._renderPopoverContent()
        return
      }

      const day = e.target.closest("[data-miti-day]")
      if (day) {
        if (this._wasDragged) { this._wasDragged = false; return }
        this._selectDay(day)
        return
      }

      const today = e.target.closest("[data-miti-today]")
      if (today) {
        e.preventDefault()
        this._goToday()
      }
    })

    this._renderPopoverContent()
  }

  _parseDates() {
    const parse = (input) => {
      if (!input?.value) return null
      const parts = input.value.split(/[-\/]/)
      if (parts.length !== 3) return null
      return { barsa: parseInt(parts[0], 10), mahina: parseInt(parts[1], 10), gatey: parseInt(parts[2], 10) }
    }
    this.startDate = parse(this.startInput)
    this.endDate = parse(this.endInput)

    if (!this.startInput && this.displayInput?.value) {
      const parts = this.displayInput.value.split(/\s*[—–-]\s*/)
      if (parts.length === 2) {
        this.startDate = parse({ value: parts[0].trim() })
        this.endDate = parse({ value: parts[1].trim() })
      } else {
        this.startDate = parse({ value: parts[0]?.trim() })
      }
    }

    const ref = this.startDate || this.endDate
    if (ref) {
      this.currentYear = ref.barsa
      this.currentMonth = ref.mahina
    }
    if (!this.currentYear || !this.currentMonth) {
      const today = MitiConverter.today()
      if (today) {
        this.currentYear = today.barsa
        this.currentMonth = today.mahina
      }
    }
  }

  _renderPopoverContent() {
    if (!this.popover) return
    if (this.view === "day") this._renderDayView()
    else if (this.view === "month") this._renderMonthView()
    else if (this.view === "year") this._renderYearView()
  }

  _renderDayView() {
    const months = MitiConverter.monthsEnglish()
    const monthName = months[this.currentMonth - 1]
    const daysInMonth = MitiConverter.daysInMonth(this.currentYear, this.currentMonth)
    const startWday = MitiConverter.monthStartWeekday(this.currentYear, this.currentMonth)
    const today = MitiConverter.today()

    let html = `<div class="miti-date-picker__nav">`
    html += `<button type="button" class="miti-date-picker__nav-btn" data-miti-nav="prev">&larr;</button>`
    const showYear = !today || this.currentYear !== today.barsa
    html += `<span class="miti-date-picker__title" data-miti-title>${monthName}${showYear ? ` ${this.currentYear}` : ""}</span>`
    html += `<button type="button" class="miti-date-picker__nav-btn" data-miti-nav="next">&rarr;</button>`
    html += `</div>`

    html += `<table class="miti-date-picker__calendar"><thead><tr>`
    ;["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"].forEach((d) => {
      html += `<th class="miti-date-picker__header">${d}</th>`
    })
    html += `</tr></thead><tbody>`

    let cellIdx = 0
    for (let r = 0; r < 6; r++) {
      html += `<tr>`
      for (let c = 0; c < 7; c++) {
        if (r === 0 && c < startWday) {
          html += `<td class="miti-date-picker__day miti-date-picker__day--other"></td>`
          cellIdx++
        } else if (cellIdx - startWday + 1 <= daysInMonth) {
          const gatey = cellIdx - startWday + 1
          const isToday = today && today.barsa === this.currentYear && today.mahina === this.currentMonth && today.gatey === gatey

          let cls = "miti-date-picker__day"
          if (isToday) cls += " miti-date-picker__day--today"
          if (c === 0) cls += " miti-date-picker__day--sun"
          if (c === 6) cls += " miti-date-picker__day--sat"

          const inRange = this._isInRange(this.currentYear, this.currentMonth, gatey)
          if (inRange) cls += " miti-date-picker__day--in-range"
          if (this._isRangeStart(this.currentYear, this.currentMonth, gatey)) cls += " miti-date-picker__day--range-start"
          if (this._isRangeEnd(this.currentYear, this.currentMonth, gatey)) cls += " miti-date-picker__day--range-end"

          html += `<td class="${cls}" data-miti-day data-gatey="${gatey}" data-barsa="${this.currentYear}" data-mahina="${this.currentMonth}" role="button" tabindex="-1">${gatey}</td>`
          cellIdx++
        } else {
          html += `<td class="miti-date-picker__day miti-date-picker__day--other"></td>`
          cellIdx++
        }
      }
      html += `</tr>`
      if (cellIdx - startWday >= daysInMonth) break
    }

    html += `</tbody></table>`

    const hint = (this.startDate && !this.endDate) ? "Select end date" : ""
    if (hint) {
      html += `<div class="miti-date-picker__footer miti-date-picker__footer--hint">${hint}</div>`
    } else if (today) {
      html += `<div class="miti-date-picker__footer"><button type="button" class="miti-date-picker__today-btn" data-miti-today>Today</button></div>`
    }

    this.popover.innerHTML = html
  }

  _renderMonthView() {
    const months = MitiConverter.monthsEnglish()
    const today = MitiConverter.today()

    const showYear = !today || this.currentYear !== today.barsa
    let html = `<div class="miti-date-picker__nav">`
    html += `<button type="button" class="miti-date-picker__nav-btn" data-miti-nav="prev">&larr;</button>`
    html += `<span class="miti-date-picker__title" data-miti-title>${showYear ? this.currentYear : ""}</span>`
    html += `<button type="button" class="miti-date-picker__nav-btn" data-miti-nav="next">&rarr;</button>`
    html += `</div>`

    html += `<div class="miti-date-picker__grid">`
    for (let m = 0; m < 12; m++) {
      const isCurrent = today && today.barsa === this.currentYear && today.mahina === m + 1
      const isSelected = m + 1 === this.currentMonth
      let cls = "miti-date-picker__cell"
      if (isCurrent) cls += " miti-date-picker__cell--today"
      if (isSelected) cls += " miti-date-picker__cell--selected"
      html += `<div class="${cls}" data-miti-pick="${m + 1}" role="button" tabindex="-1">${months[m]}</div>`
    }
    html += `</div>`

    this.popover.innerHTML = html
  }

  _renderYearView() {
    const today = MitiConverter.today()
    const startYear = Math.floor(this.currentYear / 10) * 10

    let html = `<div class="miti-date-picker__nav">`
    html += `<button type="button" class="miti-date-picker__nav-btn" data-miti-nav="prev">&larr;</button>`
    html += `<span class="miti-date-picker__title" data-miti-title>${startYear}–${startYear + 9}</span>`
    html += `<button type="button" class="miti-date-picker__nav-btn" data-miti-nav="next">&rarr;</button>`
    html += `</div>`

    html += `<div class="miti-date-picker__grid">`
    for (let y = startYear; y < startYear + 10; y++) {
      const isCurrent = today && today.barsa === y
      const isSelected = y === this.currentYear
      let cls = "miti-date-picker__cell"
      if (isCurrent) cls += " miti-date-picker__cell--today"
      if (isSelected) cls += " miti-date-picker__cell--selected"
      html += `<div class="${cls}" data-miti-pick="${y}" role="button" tabindex="-1">${y}</div>`
    }
    html += `</div>`

    this.popover.innerHTML = html
  }

  _navPrev() {
    if (this.view === "day") {
      if (this.currentMonth === 1) { this.currentMonth = 12; this.currentYear-- }
      else { this.currentMonth-- }
    } else if (this.view === "month") { this.currentYear-- }
    else if (this.view === "year") { this.currentYear -= 10 }
    this._renderPopoverContent()
  }

  _navNext() {
    if (this.view === "day") {
      if (this.currentMonth === 12) { this.currentMonth = 1; this.currentYear++ }
      else { this.currentMonth++ }
    } else if (this.view === "month") { this.currentYear++ }
    else if (this.view === "year") { this.currentYear += 10 }
    this._renderPopoverContent()
  }

  _selectDay(dayEl) {
    const gatey = parseInt(dayEl.dataset.gatey, 10)
    const barsa = parseInt(dayEl.dataset.barsa, 10)
    const mahina = parseInt(dayEl.dataset.mahina, 10)

    if (this.startDate && this.endDate) {
      const clickedVal = this._dateToValue(barsa, mahina, gatey)
      const startVal = this._dateToValue(this.startDate.barsa, this.startDate.mahina, this.startDate.gatey)
      const endVal = this._dateToValue(this.endDate.barsa, this.endDate.mahina, this.endDate.gatey)

      if (clickedVal < startVal) {
        this.startDate = { barsa, mahina, gatey }
        this.currentYear = barsa
        this.currentMonth = mahina
        this._renderPopoverContent()
        this._dispatchChange("start")
      } else if (clickedVal > endVal) {
        this.endDate = { barsa, mahina, gatey }
        this._updateInputs()
        this.close()
      }
      return
    }

    if (!this.startDate) {
      this.startDate = { barsa, mahina, gatey }
      this.endDate = null
      this.currentYear = barsa
      this.currentMonth = mahina
      this._renderPopoverContent()
      this._dispatchChange("start")
    } else {
      if (this._dateToValue(barsa, mahina, gatey) < this._dateToValue(this.startDate.barsa, this.startDate.mahina, this.startDate.gatey)) {
        this.startDate = { barsa, mahina, gatey }
        this.currentYear = barsa
        this.currentMonth = mahina
        this._renderPopoverContent()
        this._dispatchChange("start")
      } else {
        this.endDate = { barsa, mahina, gatey }
        this._updateInputs()
        this.close()
      }
    }
  }

  _startDrag(dayEl) {
    const gatey = parseInt(dayEl.dataset.gatey, 10)
    const barsa = parseInt(dayEl.dataset.barsa, 10)
    const mahina = parseInt(dayEl.dataset.mahina, 10)
    this._dragStart = { barsa, mahina, gatey }
    this._dragActive = false
  }

  _updateDrag(dayEl) {
    if (!this._dragStart) return

    const gatey = parseInt(dayEl.dataset.gatey, 10)
    const barsa = parseInt(dayEl.dataset.barsa, 10)
    const mahina = parseInt(dayEl.dataset.mahina, 10)

    if (!this._dragActive) {
      this._dragActive = true
      this.startDate = null
      this.endDate = null
    }

    const startVal = this._dateToValue(this._dragStart.barsa, this._dragStart.mahina, this._dragStart.gatey)
    const currentVal = this._dateToValue(barsa, mahina, gatey)

    if (currentVal < startVal) {
      this.startDate = { barsa, mahina, gatey }
      this.endDate = { ...this._dragStart }
    } else {
      this.startDate = { ...this._dragStart }
      this.endDate = { barsa, mahina, gatey }
    }

    this.currentYear = barsa
    this.currentMonth = mahina

    if (this._dragRaf) cancelAnimationFrame(this._dragRaf)
    this._dragRaf = requestAnimationFrame(() => this._renderPopoverContent())
  }

  _endDrag(e) {
    if (!this._dragStart) return

    if (this._dragActive) {
      e.preventDefault()
      this._wasDragged = true
      if (this.startDate && this.endDate) {
        this._updateInputs()
        this.close()
      }
    }

    this._dragStart = null
    this._dragActive = false
    if (this._dragRaf) {
      cancelAnimationFrame(this._dragRaf)
      this._dragRaf = null
    }
  }

  _goToday() {
    const today = MitiConverter.today()
    if (!today) return
    this.currentYear = today.barsa
    this.currentMonth = today.mahina
    this.startDate = { barsa: today.barsa, mahina: today.mahina, gatey: today.gatey }
    this.endDate = { barsa: today.barsa, mahina: today.mahina, gatey: today.gatey }
    this.view = "day"
    this._renderPopoverContent()
    this._updateInputs()
    this.close()
  }

  _updateInputs() {
    if (this.startDate) {
      const formatted = MitiConverter.formatBs(this.startDate.barsa, this.startDate.mahina, this.startDate.gatey)
      if (this.startInput) this.startInput.value = formatted
    }
    if (this.endDate) {
      const formatted = MitiConverter.formatBs(this.endDate.barsa, this.endDate.mahina, this.endDate.gatey)
      if (this.endInput) this.endInput.value = formatted
    }
    if (this.displayInput) {
      this.displayInput.value = this._formatRangeDisplay()
    }
    this._dispatchChange("end")
    this.element.dispatchEvent(new CustomEvent("miti:range-selected", {
      bubbles: true,
      detail: {
        startDate: this.startDate ? MitiConverter.formatBs(this.startDate.barsa, this.startDate.mahina, this.startDate.gatey) : null,
        endDate: this.endDate ? MitiConverter.formatBs(this.endDate.barsa, this.endDate.mahina, this.endDate.gatey) : null
      }
    }))
  }

  _updateDisplayOnly() {
    if (this.displayInput) {
      this.displayInput.value = this._formatRangeDisplay()
    }
  }

  _formatRangeDisplay() {
    if (!this.startDate || !this.endDate) {
      if (this.startDate) {
        return MitiConverter.formatBs(this.startDate.barsa, this.startDate.mahina, this.startDate.gatey)
      }
      return ""
    }

    const td = MitiConverter.today()
    const months = MitiConverter.monthsEnglish()
    const isCurrentYear = td && this.startDate.barsa === td.barsa && this.endDate.barsa === td.barsa
    const sameYear = this.startDate.barsa === this.endDate.barsa
    const sameMonth = sameYear && this.startDate.mahina === this.endDate.mahina

    if (sameMonth) {
      const m = months[this.startDate.mahina - 1]
      return `${m} ${this.startDate.gatey}–${this.endDate.gatey}${isCurrentYear ? "" : `, ${this.startDate.barsa}`}`
    }

    const sm = months[this.startDate.mahina - 1]
    const em = months[this.endDate.mahina - 1]

    if (isCurrentYear) {
      return `${sm} ${this.startDate.gatey} – ${em} ${this.endDate.gatey}`
    }

    return `${sm} ${this.startDate.gatey}, ${this.startDate.barsa} – ${em} ${this.endDate.gatey}, ${this.endDate.barsa}`
  }

  _dispatchChange(field) {
    const input = field === "end" ? this.endInput : this.startInput
    if (!input) return
    input.dispatchEvent(new Event("input", { bubbles: true }))
    input.dispatchEvent(new Event("change", { bubbles: true }))
  }

  _reposition() {
    if (!this.popover || !this._activeInput) return
    const rect = this._activeInput.getBoundingClientRect()
    const pw = this.popover.offsetWidth || 280
    const ph = this.popover.offsetHeight || 300
    const below = window.innerHeight - rect.bottom
    const above = rect.top

    let left = rect.left + window.scrollX
    let top

    if (below >= ph + 4 || below >= above) {
      top = rect.bottom + window.scrollY + 4
    } else {
      top = rect.top + window.scrollY - ph - 4
    }

    if (left + pw > window.innerWidth) left = window.innerWidth - pw - 8
    if (left < 0) left = 8

    this.popover.style.position = "absolute"
    this.popover.style.left = `${left}px`
    this.popover.style.top = `${top}px`
  }

  _dateToValue(barsa, mahina, gatey) {
    return barsa * 10000 + mahina * 100 + gatey
  }

  _isInRange(barsa, mahina, gatey) {
    if (!this.startDate) return false
    const val = this._dateToValue(barsa, mahina, gatey)
    const startVal = this._dateToValue(this.startDate.barsa, this.startDate.mahina, this.startDate.gatey)
    if (!this.endDate) return val === startVal
    const endVal = this._dateToValue(this.endDate.barsa, this.endDate.mahina, this.endDate.gatey)
    return val >= startVal && val <= endVal
  }

  _isRangeStart(barsa, mahina, gatey) {
    if (!this.startDate) return false
    return this.startDate.barsa === barsa && this.startDate.mahina === mahina && this.startDate.gatey === gatey
  }

  _isRangeEnd(barsa, mahina, gatey) {
    if (!this.endDate) return false
    return this.endDate.barsa === barsa && this.endDate.mahina === mahina && this.endDate.gatey === gatey
  }

  _clearBlurTimeout() {
    if (this.blurTimeout) {
      clearTimeout(this.blurTimeout)
      this.blurTimeout = null
    }
  }

  _isClickInsidePopover(event) {
    if (!this.popover) return false
    const relatedTarget = event.relatedTarget
    if (relatedTarget && this.popover.contains(relatedTarget)) return true
    const target = event.target
    if (target && this.popover.contains(target)) return true
    return false
  }

  _selectFocusedDay() {
    if (this.view !== "day") return
    const focused = this.popover?.querySelector(".miti-date-picker__day:focus")
    if (focused?.dataset.gatey) { this._selectDay(focused); return }
    const selected = this.popover?.querySelector(".miti-date-picker__day--selected[data-gatey]")
    if (selected) this._selectDay(selected)
  }
}
