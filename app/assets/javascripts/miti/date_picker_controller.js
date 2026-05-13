import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { value: String }
  static classes = { open: "miti-date-picker--open" }

  connect() {
    this.popover = null
    this.currentYear = null
    this.currentMonth = null
    this.input = this.element
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
      this.element.classList.add(...this.openClass)
      return
    }

    this._buildPopover()
    this._positionPopover()

    document.body.appendChild(this.popover)
    this.element.classList.add(...this.openClass)

    requestAnimationFrame(() => {
      this._positionPopover()
    })
  }

  close() {
    this._clearBlurTimeout()
    if (this.popover) {
      this.popover.style.display = "none"
    }
    if (this.openClass.length) {
      this.element.classList.remove(...this.openClass)
    }
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
        this.close()
        this.input.focus()
        break
      case "Enter":
        event.preventDefault()
        this._selectFocusedDay()
        break
      case "ArrowUp":
        event.preventDefault()
        this._moveFocus(-7)
        break
      case "ArrowDown":
        event.preventDefault()
        this._moveFocus(7)
        break
      case "ArrowLeft":
        event.preventDefault()
        this._moveFocus(-1)
        break
      case "ArrowRight":
        event.preventDefault()
        this._moveFocus(1)
        break
    }
  }

  selectDay(event) {
    const gatey = parseInt(event.currentTarget.dataset.gatey, 10)
    const barsa = parseInt(event.currentTarget.dataset.barsa, 10)
    const mahina = parseInt(event.currentTarget.dataset.mahina, 10)
    this._setValue(barsa, mahina, gatey)
    this.close()
    this.input.focus()
  }

  prevMonth(event) {
    if (event) event.preventDefault()
    if (this.currentMonth === 1) {
      this.currentMonth = 12
      this.currentYear--
    } else {
      this.currentMonth--
    }
    this._renderPopoverContent()
  }

  nextMonth(event) {
    if (event) event.preventDefault()
    if (this.currentMonth === 12) {
      this.currentMonth = 1
      this.currentYear++
    } else {
      this.currentMonth++
    }
    this._renderPopoverContent()
  }

  _buildPopover() {
    this._parseInitialDate()

    this.popover = document.createElement("div")
    this.popover.className = "miti-date-picker-popover"
    this.popover.setAttribute("data-miti-date-picker-target", "popover")

    this.popover.addEventListener("mousedown", (e) => {
      this._clearBlurTimeout()
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

    const months = MitiConverter.monthsEnglish()
    const monthName = months[this.currentMonth - 1]
    const daysInMonth = MitiConverter.daysInMonth(this.currentYear, this.currentMonth)
    const startWday = MitiConverter.monthStartWeekday(this.currentYear, this.currentMonth)
    const today = MitiConverter.today()
    const inputVal = this.input.value

    let headerHtml = `<div class="miti-date-picker__nav">`
    headerHtml += `<button type="button" class="miti-date-picker__nav-btn" data-action="miti-date-picker#prevMonth">&larr;</button>`
    headerHtml += `<span class="miti-date-picker__title">${monthName} ${this.currentYear}</span>`
    headerHtml += `<button type="button" class="miti-date-picker__nav-btn" data-action="miti-date-picker#nextMonth">&rarr;</button>`
    headerHtml += `</div>`

    let tableHtml = `<table class="miti-date-picker__calendar"><thead><tr>`
    ;["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"].forEach((d) => {
      tableHtml += `<th class="miti-date-picker__header">${d}</th>`
    })
    tableHtml += `</tr></thead><tbody>`

    let cellIdx = 0
    for (let r = 0; r < 6; r++) {
      tableHtml += `<tr>`
      for (let c = 0; c < 7; c++) {
        if (r === 0 && c < startWday) {
          tableHtml += `<td class="miti-date-picker__day miti-date-picker__day--other"></td>`
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

          tableHtml += `<td class="${cls}" data-action="click->miti-date-picker#selectDay" data-gatey="${gatey}" data-barsa="${this.currentYear}" data-mahina="${this.currentMonth}" role="button" tabindex="-1">${gatey}</td>`
          cellIdx++
        } else {
          tableHtml += `<td class="miti-date-picker__day miti-date-picker__day--other"></td>`
          cellIdx++
        }
      }
      tableHtml += `</tr>`
      if (cellIdx - startWday >= daysInMonth) break
    }

    tableHtml += `</tbody></table>`

    const todayBtn = `<div class="miti-date-picker__footer"><button type="button" class="miti-date-picker__today-btn" data-action="miti-date-picker#goToday">Today</button></div>`
    footerHtml = ``
    if (today) {
      footerHtml = todayBtn
    }

    this.popover.innerHTML = headerHtml + tableHtml + footerHtml
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
    let left = rect.left + window.scrollX
    let top = rect.bottom + window.scrollY + 4

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
    const focused = this.popover.querySelector(".miti-date-picker__day:focus")
    if (focused && focused.dataset.gatey) {
      this.selectDay({ currentTarget: focused })
    }
  }

  _moveFocus(delta) {
    const days = this.popover.querySelectorAll(".miti-date-picker__day:not(.miti-date-picker__day--other)")
    const focused = this.popover.querySelector(".miti-date-picker__day:focus")
    let idx = -1
    days.forEach((d, i) => {
      if (d === focused) idx = i
    })
    if (idx === -1) {
      days[0]?.focus()
    } else {
      const next = idx + delta
      if (next >= 0 && next < days.length) {
        days[next].focus()
      }
    }
  }

  goToday(event) {
    event.preventDefault()
    const today = MitiConverter.today()
    if (!today) return
    this.currentYear = today.barsa
    this.currentMonth = today.mahina
    this._renderPopoverContent()
    this._setValue(today.barsa, today.mahina, today.gatey)
    this.close()
    this.input.focus()
  }
}
