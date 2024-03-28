import $ from 'jquery'

$('[data-delete-ads]').on('click', (event) => {
  event.preventDefault()

  if (confirm('Are you sure you want to delete item?')) {
    $(event.currentTarget.parentElement).find('form').trigger('submit')
  }
})