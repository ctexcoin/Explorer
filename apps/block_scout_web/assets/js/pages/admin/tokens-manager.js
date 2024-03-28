import $ from 'jquery'
import Swal from 'sweetalert2'


if ($('[data-async-listing]').length) {

  $('[data-async-listing]').on('click', '.data-update-tokens', event => {
    event.preventDefault()
  
    const url = $(event.currentTarget).data('action');
    if (url && confirm('Are you sure you want to verify them to tick/untick?')) {
      $.ajax({
        url,
        type: 'POST',
        data: JSON.stringify({ _csrf_token: $(event.currentTarget).data('csrf') }),
        dataType: 'json',
        contentType: 'application/json; charset=utf-8',
        beforeSend: function(xhr){
          xhr.withCredentials = true;
        }
      }).done(response => {
        if (response.success) {
          Swal.fire({
            title: 'Success',
            html: (response.sticked ? 'Active' : 'Deactive') + ' Tick Successful!',
            icon: 'success'
          })
          $(event.currentTarget).find('img').attr('src', '/images/icons/' + (response.sticked ? 'ticked' : 'untick') + '.png')
        } else {
          Swal.fire({
            title: 'Warning',
            html: formatError(response.msg),
            icon: 'warning'
          })
        }
      })
      .fail(() => {
        Swal.fire({
          title: 'Warning',
          html: 'System Error. Please try again',
          icon: 'warning'
        })})
    }
  })
}
