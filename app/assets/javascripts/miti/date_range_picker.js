import MitiDatePicker from "miti/date_picker"

export default class MitiDateRangePicker {
  constructor(element) {
    this.element = element
    this.startWrapper = element.querySelector(".miti-date-range__field--start")
    this.endWrapper = element.querySelector(".miti-date-range__field--end")
    this.startPicker = null
    this.endPicker = null
    this._listeners = []
  }

  attach() {
    if (this._attached) return
    this._attached = true

    if (this.startWrapper) {
      this.startPicker = new MitiDatePicker(this.startWrapper)
      this.startPicker.attach()
      this._on(this.startPicker.input, "miti:selected", () => {
        setTimeout(() => this.endWrapper?.querySelector(".miti-date-field")?.focus(), 100)
      })
    }

    if (this.endWrapper) {
      this.endPicker = new MitiDatePicker(this.endWrapper)
      this.endPicker.attach()
    }
  }

  destroy() {
    this.startPicker?.destroy()
    this.endPicker?.destroy()
    this._listeners.forEach(({ el, type, handler }) => el.removeEventListener(type, handler))
    this._listeners = []
  }

  _on(el, type, handler) {
    el.addEventListener(type, handler)
    this._listeners.push({ el, type, handler })
  }
}
