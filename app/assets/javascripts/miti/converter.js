const MitiConverter = {
  data: null,

  init() {
    if (this.data) return
    const el = document.getElementById("miti-calendar-data")
    if (!el) return
    try {
      this.data = JSON.parse(el.textContent)
    } catch (e) {
      console.warn("Miti: failed to parse calendar data", e)
    }
  },

  monthsEnglish() {
    this.init()
    return this.data ? this.data.monthsEnglish : []
  },

  monthsNepali() {
    this.init()
    return this.data ? this.data.monthsNepali : []
  },

  weekdaysEnglish() {
    this.init()
    return this.data ? this.data.weekdaysEnglish : []
  },

  weekdaysNepali() {
    this.init()
    return this.data ? this.data.weekdaysNepali : []
  },

  daysInMonth(barsa, mahina) {
    this.init()
    if (!this.data) return 30
    const yearData = this.data.nepaliYearMonthHash[String(barsa)]
    return yearData ? yearData[mahina - 1] : 30
  },

  isValidBsDate(barsa, mahina, gatey) {
    if (mahina < 1 || mahina > 12) return false
    if (gatey < 1) return false
    return gatey <= this.daysInMonth(barsa, mahina)
  },

  yday(year, month, day) {
    const date = new Date(year, month - 1, day)
    const start = new Date(year, 0, 0)
    const diff = date - start
    return Math.round(diff / (1000 * 60 * 60 * 24))
  },

  bsToAd(barsa, mahina, gatey) {
    this.init()
    if (!this.data) return null

    const baisakh1April = this.data.baishakhFirstCorrespondingApril[String(barsa)]
    if (!baisakh1April) return null

    const adYear = barsa - 57
    const baisakh1Ad = new Date(adYear, 3, baisakh1April)

    let daysToAdd = 0
    const yearData = this.data.nepaliYearMonthHash[String(barsa)]
    if (!yearData) return null

    for (let m = 0; m < mahina - 1; m++) {
      daysToAdd += yearData[m]
    }
    daysToAdd += gatey - 1

    const result = new Date(baisakh1Ad)
    result.setDate(result.getDate() + daysToAdd)
    return {
      year: result.getFullYear(),
      month: result.getMonth() + 1,
      day: result.getDate()
    }
  },

  adToBs(year, month, day) {
    this.init()
    if (!this.data) return null

    const gateyJan1 = this.data.janFirstCorrespondingGatey[String(year)]
    if (!gateyJan1) return null

    const bsYear = year + 56
    const targetYday = this.yday(year, month, day)
    let dayCount = 1 - gateyJan1

    const yearData = this.data.nepaliYearMonthHash[String(bsYear)]
    if (!yearData) return null

    for (let m = 8; m < yearData.length; m++) {
      dayCount += yearData[m]
      if (dayCount >= targetYday) {
        const computedGatey = dayCount === targetYday
          ? yearData[m]
          : targetYday - (dayCount - yearData[m])
        return { barsa: bsYear, mahina: m + 1, gatey: computedGatey }
      }
    }

    const nextYearData = this.data.nepaliYearMonthHash[String(bsYear + 1)]
    if (!nextYearData) return null

    for (let m = 0; m < nextYearData.length; m++) {
      dayCount += nextYearData[m]
      if (dayCount >= targetYday) {
        const computedGatey = dayCount === targetYday
          ? nextYearData[m]
          : targetYday - (dayCount - nextYearData[m])
        return { barsa: bsYear + 1, mahina: m + 1, gatey: computedGatey }
      }
    }

    return null
  },

  monthStartWeekday(barsa, mahina) {
    const ad = this.bsToAd(barsa, mahina, 1)
    if (!ad) return 0
    const date = new Date(ad.year, ad.month - 1, ad.day)
    return date.getDay()
  },

  today() {
    const now = new Date()
    return this.adToBs(now.getFullYear(), now.getMonth() + 1, now.getDate())
  },

  formatBs(barsa, mahina, gatey) {
    const m = String(mahina).padStart(2, "0")
    const d = String(gatey).padStart(2, "0")
    return `${barsa}-${m}-${d}`
  }
}

window.MitiConverter = MitiConverter
export default MitiConverter
