var ahcView = {
	ValidateGrid: function (confirmlabel,includeLob) {
		var site = $('#ddlSites').val();
		var campaign = $('#ddlCampaigns').val();
		var lobid = $('#LobID').val();
		var start = $('#txtStart').val().trim();
		var end = $('#txtEnd').val().trim();
		var msg = '';

		if (site == '0')
			msg += 'Site is required. <br \>';
		if (campaign == '0')
			msg += 'Campaign is required. <br \>';
		if (includeLob == true) {
			if (lobid == '0')
				msg += 'Lob is required. <br \>';
		}
		
		if ((start.trim() != '' && end.trim() == '') || (start.trim() == '' && end.trim() != '') || (start.trim() == '' && end.trim() == '')) {
			if (end.trim() == '')
				msg += 'End date is required.  <br \>';
			if (start.trim() == '')
				msg += 'Start date is required.  <br \>';
		}
		if (start.trim() != '' && end.trim() != '') {
			var d1 = new Date(start.trim());
			var d2 = new Date(end.trim());

			if (d2 < d1)
				msg += 'Invalid date range.  <br \>';
		}

		if (msg == '') {
			return true;
		}
		else {

			$.alert({
				closeIcon: true,
				title: confirmlabel,
				content: msg
			});
			return false;
		}
	},
    ValidateAHCGrid: function () {
    	return ahcView.ValidateGrid('WFMPCP | Assumption and Headcount', true);
    },
    ValidateStaffPlannerGrid: function () {
    	return ahcView.ValidateGrid('WFMPCP | Staff Planner', true);
    },
    ValidateHiringGrid: function(){
    	return ahcView.ValidateGrid('WFMPCP | Hiring Requirements',false);
    },
    ValidateSummaryGrid: function () {
    	return ahcView.ValidateGrid('WFMPCP | Summary 1',true);
    },
    Initialize: function () {
        $('#SiteID').val('0');
        $('#CampaignID').val('0');
        $('#LobID').val('0');
        $('#IsUpdate').hide();
    },
    LobChange: function () {
        $('#ddlLobs').change(function () {
            $('#LobID').val($('#ddlLobs').val());
        });
    },
    DateRangeFilters: function () {
    	$("#txtStart").datepicker({
    		showOtherMonths: true,
    		selectOtherMonths: false,
    		dateFormat: 'yy-mm-dd',
			beforeShowDay: function (date) {
                if (date.getDay() == 1) {
                    return [true, ''];
                }
                return [false, ''];
            }
    	}).mask("9999-99-99");

    	$("#txtEnd").datepicker({
    		showOtherMonths: true,
    		selectOtherMonths: false,
    		dateFormat: 'yy-mm-dd',
    		beforeShowDay: function (date) {
    			if (date.getDay() == 1) {
    				return [true, ''];
    			}
    			return [false, ''];
    		}
    	}).mask("9999-99-99");
        //var mindate = common.AddDays(common.GetMonday(), -7);
        ////alert(mindate)
        //$("#txtStart").datepicker({
        //    showOtherMonths: true,
        //    selectOtherMonths: false,
        //    dateFormat: 'yy-mm-dd',
        //    minDate: mindate,
        //    beforeShowDay: function (date) {
        //        if (date.getDay() == 1) {
        //            return [true, ''];
        //        }
        //        return [false, ''];
        //    }
        //}).mask("9999-99-99");
        //$("#txtEnd").datepicker({
        //    showOtherMonths: true,
        //    selectOtherMonths: false,
        //    dateFormat: 'yy-mm-dd',
        //    minDate: mindate,
        //    beforeShowDay: function (date) {
        //        if (date.getDay() == 1) {
        //            return [true, ''];
        //        }
        //        return [false, ''];
        //    }
        //}).mask("9999-99-99");
    },
}