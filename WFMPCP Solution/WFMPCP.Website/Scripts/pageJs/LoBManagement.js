var lobmanagement = {
    OnSaveClick: function (saveURL, gridTable) {
        $('#btnSave').click(function () {
            var id = $('#txtID').val();
            var name = $.trim($('#txtName').val());
            var description = $.trim($('#txtDescription').val());
            var code = $.trim($('#txtCode').val());
            var siteID =0; //$('#ddlSites').val();
            var campaignID = 0; //$('#ddlCampaigns').val();
            var siteCampaign = $('#ddlSiteCampaigns').val();

            var siteCampaignIds = "";
            $('#ddlSiteCampaigns :selected').each(function (i, sel) {
                siteCampaignIds += $(sel).val() + ',';
            });

            var msg = '';

            if (name == '')
                msg += 'LoB name is required. <br />';
            if (code == '')
                msg += 'LoB code is required. <br />';
            if (siteCampaign === null)
                msg += 'Site Campaign is required. <br />';
            //if (campaignID == '0')
            //    msg += 'Campaign is required. <br />';

            if (msg != '') {
                $.alert({
                    closeIcon: true,
                    title: 'WFMPCP | LoB Manager',
                    content: msg
                });
            }
            else {
                //save            

                //confirm first 
                $.confirm({
                    closeIcon: true,
                    title: 'WFMPCP | LoB Manager',
                    content: 'Save data?',
                    confirmButton: 'Yes',
                    cancelButton: 'No',
                    confirm: function () {
                        var model = {
                            ID: id,
                            Name: name,
                            Code: code,
                            CampaignID: campaignID,
                            Description: description,
                            SiteCampaignIds: siteCampaignIds,
                            Active: true
                        }

                        $.post(saveURL, model, function (data) {

                            if (data.Message != '') {
                                $.alert({
                                    closeIcon: true,
                                    title: 'WFMPCP | LoB Manager',
                                    content: data.Message
                                });
                            }
                            lobmanagement.ClearData(gridTable);
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
                title: 'WFMPCP | LoB Manager',
                content: 'Delete data?',
                confirmButton: 'Yes',
                cancelButton: 'No',
                confirm: function () {
                    $.post(deleteUrl, { "id": id }, function (data) {
                        var msg = $.trim(data.Message);
                        lobmanagement.ClearData(gridTable);
                        if (msg != '') {
                            $.alert({
                                closeIcon: true,
                                title: 'WFMPCP | LoB Manager',
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
            lobmanagement.ClearData(gridTable);
        });
    },
    ClearData: function (gridTable) {
        $('#txtName').val('');
        $('#txtDescription').val('');
        $('#txtCode').val('');
        $('#btnDelete').hide();
        $('#txtID').val('0');
        $('#ddlSites').val('0');
        $('#ddlCampaigns')
                .find('option')
                .remove()
                .end()
                .append('<option value="0" selected>Select Campaign</option>')
                .val('whatever'); $('#ddlCampaigns').val('0');
        $(gridTable).trigger("reloadGrid");
       
    },
    OnGridSelectRow: function (id, gridSelectUrl, campaignURL) {
        $.post(gridSelectUrl, { "id": id }, function (data) {
            $('#txtID').val(data.ID)
            $('#txtName').val(data.Name)
            $('#txtDescription').val(data.Description)
            $('#txtCode').val(data.Code);
            //$('#ddlSites').val(data.CampaignVM.SiteID);

            //lobmanagement.LoadSites(campaignURL, data.CampaignVM.SiteID, data.CampaignID);
            $("#ddlSiteCampaigns option:selected").removeAttr("selected");

            var values = data.SiteCampaignIds;
            $.each(values.split(","), function (i, e) {
                $("#ddlSiteCampaigns option[value='" + e + "']").prop("selected", true);
                //$('#ddlSites').val(e);
            });
        }, 'json');
    },
    OnSiteChange: function (campaignURL) {
        $('#ddlSites').change(function () {
            var siteID = $('#ddlSites').val();

            lobmanagement.LoadSites(campaignURL, siteID, "0");
        });
    },
    LoadSites: function (campaignURL, siteID, selectedID) {
        $('#ddlCampaigns')
             .find('option')
             .remove()
             .end()
             .append('<option value="0" selected>Select Campaign</option>')
             .val('whatever');

        $.post(campaignURL, { "siteID": siteID }, function (data) {
            $.each(data, function (index, value) {
                $('#ddlCampaigns').append($('<option>', { value: value.ID, text: value.Name }));
            });

            $('#ddlCampaigns').val(selectedID);
        }, 'json');
    }
}