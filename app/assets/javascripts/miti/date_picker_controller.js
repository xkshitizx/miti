import { Controller } from "@hotwired/stimulus"
import MitiDatePicker from "miti/date_picker"

export default class extends Controller {
  static values = { value: String }

  connect() {
    this._picker = new MitiDatePicker(this.element)
    this._picker.attach()
  }

  disconnect() {
    this._picker?.destroy()
  }

  open(event) { this._picker?.open(event) }
  close() { this._picker?.close() }
  blur(event) { this._picker?.blur(event) }
  keydown(event) { this._picker?.keydown(event) }
}
