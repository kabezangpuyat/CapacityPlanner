var sitemanagement = {
    OnSaveClick: function (saveURL, gridTable) {
        $('#btnSave').click(function () {
            var id = $('#txtID').val();
            var name = $.trim($('#txtName').val());
            var description = $.trim($('#txtDescription').val());
            var code = $.trim($('#txtCode').val());
            var msg = '';

            if (name == '')
                msg += 'Site name is required. <br />';
            if (code == '')
                msg += 'Site code is required. <br />';

            if (msg != '') {
                $.alert({
                    closeIcon: true,
                    title: 'WFMPCP | Site Manager',
                    content: msg
                });
            }
            else {
                //save            

                //confirm first 
                $.confirm({
                    closeIcon: true,
                    title: 'WFMPCP | Site Manager',
                    content: 'Save data?',
                    confirmButton: 'Yes',
                    cancelButton: 'No',
                    confirm: function () {
                        var model = {
                            ID: id,
                            Name: name,
                            Code: code,
                            Description: description,
                            Active: true
                        }

                        $.post(saveURL, model, function (data) {

                            if (data.Message != '') {
                                $.alert({
                                    closeIcon: true,
                                    title: 'WFMPCP | Site Manager',
                                    content: data.Message
                                });
                            }
                            sitemanagement.ClearData(gridTable);
                        }, 'json');
                    }
                });
            }
        });      
    },
    OnDeleteClick: function (deleteUrl, gridTable) {
        $('#btnDelete').click(function () {
            var id = $('#txtID').val();

            $.confirm({
                closeIcon: true,
                title: 'WFMPCP | Site Manager',
                content: 'Delete data?',
                confirmButton: 'Yes',
                cancelButton: 'No',
                confirm: function () {
                    $.post(deleteUrl, { "id": id }, function (data) {
                        var msg = $.trim(data.Message);
                        sitemanagement.ClearData(gridTable);
                        if (msg != '') {
                            $.alert({
                                closeIcon: true,
                                title: 'WFMPCP | Site Manager',
                                content: msg
                            });
                        }
                    }, 'json');
                }
            });
        });
    },
    OnCancel: function (gridTable) {
        $('#btnCancel').click(function () {
            sitemanagement.ClearData(gridTable);
        });
    },
    ClearData: function (gridTable) {
        $('#txtName').val('');
        $('#txtDescription').val('');
        $('#txtCode').val('');
        $('#btnDelete').hide();
        $('#txtID').val('0');
        $(gridTable).trigger("reloadGrid");
    },
    OnGridSelectRow: function (id, gridSelectUrl) {
        $.post(gridSelectUrl, { "id": id }, function (data) {
            $('#txtID').val(data.ID)
            $('#txtName').val(data.Name)
            $('#txtDescription').val(data.Description)
            $('#txtCode').val(data.Code);
        }, 'json');
    }
}