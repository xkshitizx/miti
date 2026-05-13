import { Controller } from "@hotwired/stimulus"
import MitiConverter from "miti/converter"

const OPEN_CLASS = "miti-date-picker--open"

export default class extends Controller {
  static values = { value: String }

  connect() {
    this.popover = null
    this.currentYear = null
    this.currentMonth = null
    this.view = "day"
    this.input = this.element.querySelector(".miti-date-field")
    this.blurTimeout = null
  }

  disconnect() {
    this.close()
    if (this.popover && this.popover.parentNode) {
      this.popover.parentNode.removeChild(this.popover)
    }
    this.popover = null
  }

  open(event) {
    if (event && event.type === "focus") {
      this._clearBlurTimeout()
    }

    if (this.popover) {
      this.popover.style.display = "block"
      this.element.classList.add(OPEN_CLASS)
      return
    }

    this._parseInitialDate()
    this.view = "day"
    this._buildPopover()
    this._positionPopover()

    document.body.appendChild(this.popover)
    this.element.classList.add(OPEN_CLASS)

    requestAnimationFrame(() => {
      this._positionPopover()
    })
  }

  close() {
    this._clearBlurTimeout()
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
          this.input.focus()
        }
        break
      case "Enter":
        event.preventDefault()
        this._selectFocusedDay()
        break
    }
  }

  _buildPopover() {
    this.popover = document.createElement("div")
    this.popover.className = "miti-date-picker-popover"

    this.popover.addEventListener("mousedown", (e) => {
      this._clearBlurTimeout()
    })

    this.popover.addEventListener("click", (e) => {
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
        if (this.view === "day") {
          this.view = "month"
        } else if (this.view === "month") {
          this.view = "year"
        } else {
          this.view = "day"
        }
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
        this._selectDay({ currentTarget: day })
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

  _parseInitialDate() {
    const val = this.input.value || this.valueValue
    if (val) {
      const parts = val.split(/[-\/]/)
      if (parts.length === 3) {
        this.currentYear = parseInt(parts[0], 10)
        this.currentMonth = parseInt(parts[1], 10)
      }
    }

    if (!this.currentYear || !this.currentMonth) {
      const today = MitiConverter.today()
      this.currentYear = today.barsa
      this.currentMonth = today.mahina
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
    const inputVal = this.input.value

    let html = `<div class="miti-date-picker__nav">`
    html += `<button type="button" class="miti-date-picker__nav-btn" data-miti-nav="prev">&larr;</button>`
    html += `<span class="miti-date-picker__title" data-miti-title>${monthName} ${this.currentYear}</span>`
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
          const isSelected = gatey !== null && this._matchesValue(this.currentYear, this.currentMonth, gatey, inputVal)

          let cls = "miti-date-picker__day"
          if (isToday) cls += " miti-date-picker__day--today"
          if (isSelected) cls += " miti-date-picker__day--selected"
          if (c === 0) cls += " miti-date-picker__day--sun"
          if (c === 6) cls += " miti-date-picker__day--sat"

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

    const todayBtn = `<div class="miti-date-picker__footer"><button type="button" class="miti-date-picker__today-btn" data-miti-today>Today</button></div>`
    if (today) {
      html += todayBtn
    }

    this.popover.innerHTML = html
  }

  _renderMonthView() {
    const months = MitiConverter.monthsEnglish()
    const today = MitiConverter.today()

    let html = `<div class="miti-date-picker__nav">`
    html += `<button type="button" class="miti-date-picker__nav-btn" data-miti-nav="prev">&larr;</button>`
    html += `<span class="miti-date-picker__title" data-miti-title>${this.currentYear}</span>`
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
      if (this.currentMonth === 1) {
        this.currentMonth = 12
        this.currentYear--
      } else {
        this.currentMonth--
      }
    } else if (this.view === "month") {
      this.currentYear--
    } else if (this.view === "year") {
      this.currentYear -= 10
    }
    this._renderPopoverContent()
  }

  _navNext() {
    if (this.view === "day") {
      if (this.currentMonth === 12) {
        this.currentMonth = 1
        this.currentYear++
      } else {
        this.currentMonth++
      }
    } else if (this.view === "month") {
      this.currentYear++
    } else if (this.view === "year") {
      this.currentYear += 10
    }
    this._renderPopoverContent()
  }

  _selectDay(event) {
    const gatey = parseInt(event.currentTarget.dataset.gatey, 10)
    const barsa = parseInt(event.currentTarget.dataset.barsa, 10)
    const mahina = parseInt(event.currentTarget.dataset.mahina, 10)
    this._setValue(barsa, mahina, gatey)
    this.close()
  }

  _goToday() {
    const today = MitiConverter.today()
    if (!today) return
    this.currentYear = today.barsa
    this.currentMonth = today.mahina
    this.view = "day"
    this._renderPopoverContent()
    this._setValue(today.barsa, today.mahina, today.gatey)
    this.close()
  }

  _matchesValue(barsa, mahina, gatey, inputVal) {
    if (!inputVal) return false
    const parts = inputVal.split(/[-\/]/)
    if (parts.length !== 3) return false
    return parseInt(parts[0], 10) === barsa &&
           parseInt(parts[1], 10) === mahina &&
           parseInt(parts[2], 10) === gatey
  }

  _positionPopover() {
    if (!this.popover) return
    const rect = this.input.getBoundingClientRect()
    const popoverWidth = this.popover.offsetWidth || 280
    const popoverHeight = this.popover.offsetHeight || 300
    const spaceBelow = window.innerHeight - rect.bottom
    const spaceAbove = rect.top

    let left = rect.left + window.scrollX
    let top

    if (spaceBelow >= popoverHeight + 4 || spaceBelow >= spaceAbove) {
      top = rect.bottom + window.scrollY + 4
    } else {
      top = rect.top + window.scrollY - popoverHeight - 4
    }

    if (left + popoverWidth > window.innerWidth) {
      left = window.innerWidth - popoverWidth - 8
    }
    if (left < 0) left = 8

    this.popover.style.position = "absolute"
    this.popover.style.left = `${left}px`
    this.popover.style.top = `${top}px`
  }

  _setValue(barsa, mahina, gatey) {
    const formatted = MitiConverter.formatBs(barsa, mahina, gatey)
    this.input.value = formatted
    this.valueValue = formatted
    this.input.dispatchEvent(new Event("input", { bubbles: true }))
    this.input.dispatchEvent(new Event("change", { bubbles: true }))
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
    const focused = this.popover.querySelector(".miti-date-picker__day:focus")
    if (focused && focused.dataset.gatey) {
      this._selectDay({ currentTarget: focused })
    }
  }
}
