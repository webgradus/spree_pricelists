//= require admin/spree_backend

$(document).on('click', 'a.resolve-conflict', function(){
    var conflict_id = $(this).data('id');
    $.ajax({
        url: '/admin/conflicts/' + conflict_id,
        type: 'PUT',
        data: {
            conflict: {
                product: $(this).closest('tr').find('select#conflict_product').val(),
                action: $(this).closest('tr').find('select#conflict_action').val()
            }
        }
    });
    return false;
});
