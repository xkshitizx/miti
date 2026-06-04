import { Controller } from "@hotwired/stimulus"
import MitiDateRangePicker from "miti/date_range_picker"

export default class extends Controller {
  connect() {
    this._picker = new MitiDateRangePicker(this.element)
    this._picker.attach()
  }

  disconnect() {
    this._picker?.destroy()
  }

  openStart(event) {
    this._picker?.open(event, "start")
  }

  openEnd(event) {
    this._picker?.open(event, "end")
  }
}
