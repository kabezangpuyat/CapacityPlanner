var segmentmanagement = {
    OnSaveClick: function (saveURL, gridTable) {
        $('#btnSave').click(function () {
            var id = $('#txtID').val();
            var name = $.trim($('#txtName').val());
            var siteID = $('#ddlCategories').val();
            var visible = true;
            if ($('#ddlVisibility').val() == '0')
                visible = false;

            var active = true;
            if ($('#ddlStatus').val() == '0')
                active = false;
        

            var msg = '';

            if (name == '')
                msg += 'Name is required. <br />';
            if (siteID == '0')
                msg += 'Segment category is required. <br />';

            if (msg != '') {
                $.alert({
                    closeIcon: true,
                    title: 'WFMPCP | Segment Manager',
                    content: msg
                });
            }
            else {
                //save            

                //confirm first 
                $.confirm({
                    closeIcon: true,
                    title: 'WFMPCP | Segment Manager',
                    content: 'Save data?',
                    confirmButton: 'Yes',
                    cancelButton: 'No',
                    confirm: function () {
                        var model = {
                            ID: id,
                            Name: name,
                            SegmentCategoryID: siteID,
                            Active: active,
                            Visible: visible
                        }

                        $.post(saveURL, model, function (data) {

                            if (data.Message != '') {
                                $.alert({
                                    closeIcon: true,
                                    title: 'WFMPCP | Segment Manager',
                                    content: data.Message
                                });
                            }
                            segmentmanagement.ClearData(gridTable);
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
                title: 'WFMPCP | Segment Manager',
                content: 'Delete data?',
                confirmButton: 'Yes',
                cancelButton: 'No',
                confirm: function () {
                    $.post(deleteUrl, { "id": id }, function (data) {
                        var msg = $.trim(data.Message);
                        segmentmanagement.ClearData(gridTable);
                        if (msg != '') {
                            $.alert({
                                closeIcon: true,
                                title: 'WFMPCP | Segment Manager',
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
            segmentmanagement.ClearData(gridTable);
        });
    },
    ClearData: function (gridTable) {
        $('#txtID').val('0');
        $('#txtName').val('');        
        $('#ddlCategories').val('0');
        $('#ddlStatus').val('1');
        $('#ddlVisibility').val('1');
        $('#btnDelete').hide();
        $(gridTable).trigger("reloadGrid");
    },
    OnGridSelectRow: function (id, gridSelectUrl) {
        $.post(gridSelectUrl, { "id": id }, function (data) {
            $('#txtID').val(data.ID)
            $('#txtName').val(data.Name)
            $('#ddlCategories').val(data.SegmentCategoryID)
            var active = '1';
            if (data.Active == false)
                active = '0';

            var visible = '1';
            if (data.Visible == false)
                visible = '0';

            $('#ddlStatus').val(active);
            $('#ddlVisibility').val(visible);
           
        }, 'json');
    }
}