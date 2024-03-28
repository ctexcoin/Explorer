import ClipboardJS from 'clipboard'
import $ from 'jquery'

const clipboard = new ClipboardJS('[data-clipboard-text]')

clipboard.on('success', ({ trigger }) => {
  const copyButton = $(trigger)
  copyButton.tooltip('dispose')
  copyButton.children().tooltip('dispose')

  const originalTitle = copyButton.attr('data-original-title')

  copyButton
    .attr('data-original-title', 'Copied!')
    .tooltip('show')

  copyButton.attr('data-original-title', originalTitle)

  setTimeout(() => {
    copyButton.tooltip('dispose')
  }, 1000)
})

$('body').on('click', '.btn-copy', function() {
  let addressHash = $(this).parent().children('a').children('span').data('address-hash')
  if(!addressHash) {
    addressHash = $(this).parent().children('span').data('address-hash')
  }
  navigator.clipboard.writeText(addressHash)

  const originalTitle = $(this).data('original-title')
  $(this).attr('data-original-title', 'Copied!').tooltip('show')
  $(this).attr('data-original-title', originalTitle)

  setTimeout(() => {
    $(this).tooltip('dispose')
  }, 1000)
})