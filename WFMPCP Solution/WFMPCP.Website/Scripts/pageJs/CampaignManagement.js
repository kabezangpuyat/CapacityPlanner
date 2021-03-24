var campaignmanagement = {
    OnSaveClick: function (saveURL, gridTable) {
        $('#btnSave').click(function () {
            var id = $('#txtID').val();
            var name = $.trim($('#txtName').val());
            var description = $.trim($('#txtDescription').val());
            var code = $.trim($('#txtCode').val());
            var siteID = $('#ddlSites').val();
            var siteIDs = "";
            $('#ddlSites :selected').each(function (i, sel) {
                siteIDs += $(sel).val() + ',';
            });

            var msg = '';
        
            if (name == '')
                msg += 'Campaign name is required. <br />';
            if (code == '')
                msg += 'Campaign code is required. <br />';
            if (siteID === null)
                msg += 'Site(s) is required. <br />';

            if (msg != '') {
                $.alert({
                    closeIcon: true,
                    title: 'WFMPCP | Campaign Manager',
                    content: msg
                });
            }
            else {
                //save            

                //confirm first 
                $.confirm({
                    closeIcon: true,
                    title: 'WFMPCP | Campaign Manager',
                    content: 'Save data?',
                    confirmButton: 'Yes',
                    cancelButton: 'No',
                    confirm: function () {
                        var model = {
                            ID: id,
                            Name: name,
                            Code: code,
                            SiteIDs: siteIDs,
                            Description: description,
                            Active: true
                        }

                        $.post(saveURL, model, function (data) {

                            if (data.Message != '') {
                                $.alert({
                                    closeIcon: true,
                                    title: 'WFMPCP | Campaign Manager',
                                    content: data.Message
                                });
                            }
                            campaignmanagement.ClearData(gridTable);
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
                title: 'WFMPCP | Campaign Manager',
                content: 'Delete data?',
                confirmButton: 'Yes',
                cancelButton: 'No',
                confirm: function () {
                    $.post(deleteUrl, { "id": id }, function (data) {
                        var msg = $.trim(data.Message);
                        campaignmanagement.ClearData(gridTable);
                        if (msg != '') {
                            $.alert({
                                closeIcon: true,
                                title: 'WFMPCP | Campaign Manager',
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
            campaignmanagement.ClearData(gridTable);
        });
    },
    ClearData: function (gridTable) {
        $('#txtName').val('');
        $('#txtDescription').val('');
        $('#txtCode').val('');
        $('#btnDelete').hide();
        $('#txtID').val('0');
        $('#ddlSites').val('0');
        $(gridTable).trigger("reloadGrid");
    },
    OnGridSelectRow: function (id, gridSelectUrl) {
        $.post(gridSelectUrl, { "id": id }, function (data) {
            $('#txtID').val(data.ID)
            $('#txtName').val(data.Name)
            $('#txtDescription').val(data.Description)
            $('#txtCode').val(data.Code);
            $("#ddlSites option:selected").removeAttr("selected");

            var values = data.SiteIDs;
            $.each(values.split(","), function (i, e) {
                $("#ddlSites option[value='" + e + "']").prop("selected", true);
                //$('#ddlSites').val(e);
            });
           
           
        }, 'json');
    }
}