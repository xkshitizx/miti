import MitiConverter from "miti/converter"
import MitiDatePicker from "miti/date_picker"
import MitiDateRangePicker from "miti/date_range_picker"

MitiConverter.init()

function injectStylesheet() {
  if (document.querySelector("link[data-miti-styles]")) return
  const link = document.createElement("link")
  link.rel = "stylesheet"
  link.setAttribute("data-miti-styles", "")
  document.head.appendChild(link)

  const retry = () => {
    if (MitiConverter.data?.cssPath) {
      link.href = MitiConverter.data.cssPath
    } else {
      setTimeout(retry, 50)
    }
  }
  retry()
}

function initPickers(root) {
  root.querySelectorAll(".miti-date-field-wrapper:not([data-miti-initialized])").forEach(el => {
    el.dataset.mitiInitialized = "true"
    const picker = new MitiDatePicker(el)
    picker.attach()
  })
  root.querySelectorAll(".miti-date-range-wrapper:not([data-miti-initialized])").forEach(el => {
    el.dataset.mitiInitialized = "true"
    const picker = new MitiDateRangePicker(el)
    picker.attach()
  })
}

function boot() {
  injectStylesheet()
  initPickers(document)
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", boot)
} else {
  boot()
}

document.addEventListener("turbo:load", (e) => initPickers(e.target))
document.addEventListener("turbolinks:load", (e) => initPickers(e.target))

const observer = new MutationObserver((mutations) => {
  mutations.forEach((m) => {
    m.addedNodes.forEach((node) => {
      if (node.nodeType === 1 && node.querySelector) initPickers(node)
    })
  })
})
observer.observe(document.documentElement, { childList: true, subtree: true })
