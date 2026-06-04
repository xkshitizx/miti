import { Controller } from "@hotwired/stimulus"
import MitiDatePicker from "miti/date_picker"

export default class extends Controller {
  static values = { value: String }

  connect() {
    if (this.element.dataset.mitiInitialized) return
    this.element.dataset.mitiInitialized = "true"
    this._picker = new MitiDatePicker(this.element)
    this._picker.attach()
  }

  disconnect() {
    this._picker?.destroy()
    this._picker = null
  }

  open(event) { this._picker?.open(event) }
  close() { this._picker?.close() }
  blur(event) { this._picker?.blur(event) }
  keydown(event) { this._picker?.keydown(event) }
}
