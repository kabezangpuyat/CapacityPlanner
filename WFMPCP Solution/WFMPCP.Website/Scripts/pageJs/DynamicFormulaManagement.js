var dynamicformulamanagement = {
    OnSaveClick: function (saveURL, gridTable) {
        $('#btnSave').click(function () {
            var id = $('#txtID').val();
            var name = $.trim($('#txtName').val());
            //var description = $.trim($('#txtDescription').val());
            var code = $.trim($('#txtCode').val());
            var siteID = $('#ddlSites').val();
            var campaignID = $('#ddlCampaigns').val();
            var lobID = $('#ddlLobs').val();
			var formulaID = $('#ddlFormulas').val();

            var siteIDs = "";
            $('#ddlSites :selected').each(function (i, sel) {
                siteIDs += $(sel).val() + ',';
            });

            var msg = '';
        
            //if (name == '')
            //    msg += 'Name is required. <br />';
            //if (code == '')
            //    msg += 'Code is required. <br />';
            if (siteID === 0)
            	msg += 'Site is required. <br />';
            if (campaignID == 0)
            	msg += 'Campaign is required. <br />';
            if (lobID == 0)
            	msg += 'Lob is required. <br />';
            if (formulaID == 0)
            	msg += 'Formula is required. <br />';

            if (msg != '') {
                $.alert({
                    closeIcon: true,
                    title: 'WFMPCP | Dynamic Formula',
                    content: msg
                });
            }
            else {
                //save            

                //confirm first 
                $.confirm({
                    closeIcon: true,
                    title: 'WFMPCP | Dynamic Formula',
                    content: 'Save data?',
                    confirmButton: 'Yes',
                    cancelButton: 'No',
                    confirm: function () {
                        var model = {
                            ID: id,
                            FormulaName: name,
                            FormulaDescription: code,
                            SiteID: siteID,
                            CampaignID: campaignID,
                            LobID: lobID,
                        	FormulaID: formulaID
                        }

                        $.post(saveURL, model, function (data) {

                            if (data.Message != '') {
                                $.alert({
                                    closeIcon: true,
                                    title: 'WFMPCP | Dynamic Formula',
                                    content: data.Message
                                });
                            }
                            dynamicformulamanagement.ClearData(gridTable);
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
                        dynamicformulamanagement.ClearData(gridTable);
                        if (msg != '') {
                            $.alert({
                                closeIcon: true,
                                title: 'WFMPCP | Dynamic Formula',
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
        	dynamicformulamanagement.ClearData(gridTable);
        });
    },
    ClearData: function (gridTable) {
    	//clear campaign dropdown
    	$('#ddlCampaigns')
		   .find('option')
		   .remove()
		   .end()
		   .append('<option value="0" selected>[Select Campaign]</option>')
		   .val('whatever');
    	$('#ddlCampaigns').val('0');

    	//clear lob dropdown
    	$('#ddlLobs')
		   .find('option')
		   .remove()
		   .end()
		   .append('<option value="0" selected>[Select Lob]</option>')
		   .val('whatever');
    	$('#ddlLobs').val('0');

    	$('#ddlFormulas').val('0');
        $('#txtName').val('');
        $('#txtCode').val('');
        $('#btnDelete').hide();
        $('#txtID').val('0');
        $('#ddlSites').val('0');
        $(gridTable).trigger("reloadGrid");
        $('#btnDelete').hide();
    },
    OnGridSelectRow: function (id, gridSelectUrl, siteChangeUrl,campaignChangeUrl) {
    	$.post(gridSelectUrl, { "id": id }, function (data) {
    		$('#txtID').val(data.ID);
    		$('#txtName').val(data.FormulaName);
    		$('#txtDescription').val(data.FormulaDescription);
    		$('#ddlFormulas').val(data.FormulaID);

    		var siteID = data.SiteID;
    		var campaignID = data.CampaignID;
    		var lobID = data.LobID;
    		var formulaID = data.FormulaID;

    		$('#ddlSites').val(siteID);
    		//load campaign
    		dynamicformulamanagement.SiteChange(siteChangeUrl,campaignID);

    		////load lob
    		dynamicformulamanagement.CampaignChange(campaignChangeUrl,lobID,campaignID,siteID,0);           
           
        }, 'json');
    },
    SiteChange: function (siteChangeUrl,campaignID) {
    	//clear campaign dropdown
    	$('#ddlCampaigns')
		   .find('option')
		   .remove()
		   .end()
		   .append('<option value="0" selected>[Select Campaign]</option>')
		   .val('whatever');
    	

    	//clear lob dropdown
    	$('#ddlLobs')
		   .find('option')
		   .remove()
		   .end()
		   .append('<option value="0" selected>[Select Lob]</option>')
		   .val('whatever');
    	$('#ddlLobs').val('0');

    	var siteID = $('#ddlSites').val();
    	
    	$.post(siteChangeUrl, { "siteID": siteID }, function (data) {
    		$.each(data, function (index, value) {
    			$('#ddlCampaigns').append($('<option>', { value: value.ID, text: value.Name }));
    		});

    		$('#ddlCampaigns').val(campaignID);

    	}, 'json');
    },
    OnSiteChange: function (siteChangeUrl) {
    	$('#ddlSites').change(function () {
    		dynamicformulamanagement.SiteChange(siteChangeUrl,0);
    	});
    	
    },
    CampaignChange: function (campaignChangeUrl, lobid, cid, sid, isOnchange) {
    	var campaignID = $('#ddlCampaigns').val();
    	var siteID = $('#ddlSites').val();    	
    
    	if (isOnchange == 0) {
    		if (sid > 0)
    			siteID = sid;

    		if (cid > 0)
    			campaignID = cid;
    	}
    	//alert(campaignID);
    	//alert(siteID);
    	//clear lob
    	$('#ddlLobs')
		   .find('option')
		   .remove()
		   .end()
		   .append('<option value="0" selected>[Select Lob]</option>')
		   .val('whatever');
    	

    	$.post(campaignChangeUrl, { "siteID": siteID, "campaignID": campaignID }, function (data) {
    		$.each(data, function (index, value) {
    			$('#ddlLobs').append($('<option>', { value: value.ID, text: value.Name }));
    		});

    		$('#ddlLobs').val(lobid);
    	}, 'json');
    },
    OnCampaignChange: function (campaignChangeUrl) {
    	$('#ddlCampaigns').change(function () {
    		dynamicformulamanagement.CampaignChange(campaignChangeUrl,0,0,0,1);
    	});
    }
}