import { Controller } from "@hotwired/stimulus"
import MitiDateRangePicker from "miti/date_range_picker"

export default class extends Controller {
  connect() {
    if (this.element.dataset.mitiInitialized) return
    this.element.dataset.mitiInitialized = "true"
    this._picker = new MitiDateRangePicker(this.element)
    this._picker.attach()
  }

  disconnect() {
    this._picker?.destroy()
    this._picker = null
  }

  openStart(event) {
    this._picker?.open(event, "start")
  }

  openEnd(event) {
    this._picker?.open(event, "end")
  }
}
