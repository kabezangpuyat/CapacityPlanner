var ahcManagement05022018 = {
    ValidateAHCGrid: function () {
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
        if (lobid == '0')
            msg += 'Lob is required. <br \>';
        if (start == '')
            msg += 'Please select start date. <br />';
        if(end == '')
            msg += 'Please select end date. <br />';

        if (msg == '') {
        
            if ($('#btnSave').is(':visible') === true) {
                $.confirm({
                    closeIcon: true,
                    title: 'WFMPCP | AHC Manager',
                    content: 'This will disregard your changes. Do you want to continue?',
                    confirmButton: 'Yes',
                    cancelButton: 'No',
                    confirm: function () {
                        return true;
                    },
                    cancel: function () {
                        $('#divLoading').hide();
                        //return false;
                    }
                });
            }
            else {
                $('#btnSave').show();
                return true;
            }
        }
        else {

            $.alert({
                closeIcon: true,
                title: 'WFMPCP | AHC Manager',
                content: msg
            });
            return false;
        }
    },
    InitializeGridInput: function(){
        var datearray = $('#txtDates').val().split(',');
        $.each(datearray, function (i) {
            //PCP input
            $('#txt_1' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_1' + datearray[i]);
            });
            $('#txt_2' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_2' + datearray[i]);
            });
            $('#txt_3' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_3' + datearray[i]);
            });
            $('#txt_4' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_4' + datearray[i]);
            });
            $('#txt_5' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_5' + datearray[i]);
            });
            $('#txt_6' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_6' + datearray[i]);
            });
            $('#txt_7' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_7' + datearray[i]);
            });
            $('#txt_8' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_8' + datearray[i]);
            });
            $('#txt_9' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_9' + datearray[i]);
            });
            $('#txt_10' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_10' + datearray[i]);
            });
            $('#txt_11' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_11' + datearray[i]);
            });
            $('#txt_19' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_19' + datearray[i]);
            });
            $('#txt_20' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_20' + datearray[i]);
            });
            $('#txt_21' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_21' + datearray[i]);
            });
            $('#txt_22' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_22' + datearray[i]);
            });
            $('#txt_24' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_24' + datearray[i]);
            });
            $('#txt_25' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_25' + datearray[i]);
            });
            $('#txt_28' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_28' + datearray[i]);
            });
            $('#txt_29' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_29' + datearray[i]);
            });
            $('#txt_30' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_30' + datearray[i]);
            });
            $('#txt_31' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_31' + datearray[i]);
            });
            $('#txt_33' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_33' + datearray[i]);
            });
            $('#txt_34' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_34' + datearray[i]);
            });
            $('#txt_37' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_37' + datearray[i]);
            });
            $('#txt_38' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_38' + datearray[i]);
            });
            $('#txt_39' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_39' + datearray[i]);
            });
            $('#txt_40' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_40' + datearray[i]);
            });
            $('#txt_42' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_42' + datearray[i]);
            });
            $('#txt_43' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_43' + datearray[i]);
            });
            $('#txt_46' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_46' + datearray[i]);
            });
            $('#txt_47' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_47' + datearray[i]);
            });
            $('#txt_48' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_48' + datearray[i]);
            });
            $('#txt_49' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_49' + datearray[i]);
            });
            $('#txt_51' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_51' + datearray[i]);
            });
            $('#txt_52' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_52' + datearray[i]);
            });
            $('#txt_50' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_50' + datearray[i]);
            });

            $('#txt_54' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_54' + datearray[i]);
            });
            $('#txt_55' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_55' + datearray[i]);
            });
            $('#txt_56' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_56' + datearray[i]);
            });
            $('#txt_57' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_57' + datearray[i]);
            });
            $('#txt_58' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_58' + datearray[i]);
            });
            $('#txt_59' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_59' + datearray[i]);
            });
            $('#txt_60' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_60' + datearray[i]);
            });
            $('#txt_61' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_61' + datearray[i]);
            });
            $('#txt_62' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_62' + datearray[i]);
            });
            $('#txt_63' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_63' + datearray[i]);
            });
            $('#txt_64' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_64' + datearray[i]);
            });
            $('#txt_65' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_65' + datearray[i]);
            });

            $('#txt_67' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_67' + datearray[i]);
            });
            $('#txt_73' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_73' + datearray[i]);
            });
            $('#txt_74' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_74' + datearray[i]);
            });
            $('#txt_75' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_75' + datearray[i]);
            });
            $('#txt_76' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_76' + datearray[i]);
            });
            $('#txt_77' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_77' + datearray[i]);
            });
            $('#txt_78' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_78' + datearray[i]);
            });
            $('#txt_82' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_82' + datearray[i]);
            });
            $('#txt_92' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_92' + datearray[i]);
            });
            $('#txt_93' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_93' + datearray[i]);
            });
            $('#txt_94' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_94' + datearray[i]);
            });
            $('#txt_96' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_96' + datearray[i]);
            });
            $('#txt_98' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_98' + datearray[i]);
            });
            $('#txt_100' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_100' + datearray[i]);
            });
            $('#txt_102' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_102' + datearray[i]);
            });
            $('#txt_104' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_104' + datearray[i]);
            });
            $('#txt_107' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_107' + datearray[i]);
            });
            $('#txt_110' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_110' + datearray[i]);
            });
            $('#txt_113' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_113' + datearray[i]);
            });
            $('#txt_116' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_116' + datearray[i]);
            });
            $('#txt_117' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_117' + datearray[i]);
            });
        });
        
    },
    Initialize: function () {
        $('#SiteID').val('0');
        $('#CampaignID').val('0');
        $('#LobID').val('0');
        $('#txtNames').hide();
        $('#IsUpdate').hide();

        //hide widget
        $('#divWidgetBody').hide();
        $('#divWidgetBox').attr('class','widget-box collapsed');
        $('#iIcon').attr('class', 'ace-icon fa fa-chevron-down');
    },    
    LobChange: function () {
        $('#ddlLobs').change(function () {
            $('#btnSave').hide();
            $('#LobID').val($('#ddlLobs').val());
            $('#ddlLobs2').val($('#ddlLobs').val());
        });
    },
    SiteChange: function (siteChangeURL) {
        $('#ddlSites').change(function () {
            var siteid = $('#ddlSites').val();
            ahcManagement.Initialize();
            $('#SiteID').val(siteid);
            $('#ddlSites2').val($('#ddlSites').val());

            $('#ddlCampaigns')
               .find('option')
               .remove()
               .end()
               .append('<option value="0" selected>[Select Campaign]</option>')
               .val('whatever');

            $('#ddlCampaigns2')
               .find('option')
               .remove()
               .end()
               .append('<option value="0" selected>[Select Campaign]</option>')
               .val('whatever');

            $('#ddlLobs')
               .find('option')
               .remove()
               .end()
               .append('<option value="0" selected>[Select LoB]</option>')
               .val('whatever');

            $('#ddlLobs').val('0');
            $('#btnSave').hide();

            $.post(siteChangeURL, { "siteID": siteid }, function (data) {
                $.each(data, function (index, value) {
                    $('#ddlCampaigns').append($('<option>', { value: value.ID, text: value.Name }));

                    $('#ddlCampaigns2').append($('<option>', { value: value.ID, text: value.Name }));
                });
            }, 'json');
            //call httpost
        });
    },
    SiteChange2: function (siteChangeURL) {
        $('#ddlSites2').change(function () {
            var siteid = $('#ddlSites2').val();
            ahcManagement.Initialize();
            
            $('#ddlCampaigns2')
               .find('option')
               .remove()
               .end()
               .append('<option value="0" selected>[Select Campaign]</option>')
               .val('whatever');

            $.post(siteChangeURL, { "siteID": siteid }, function (data) {
                $.each(data, function (index, value) {
                    $('#ddlCampaigns2').append($('<option>', { value: value.ID, text: value.Name }));
                });
            }, 'json');
            //call httpost
        });
    },
    CampaignChange: function (campaignChangeURL) {
        $('#ddlCampaigns').change(function () {
            $('#btnSave').hide();
            var campaignID = $('#ddlCampaigns').val();
            var siteID = $('#ddlSites').val();
            ahcManagement.Initialize();

            $('#SiteID').val($('#ddlSites').val());
            $('#CampaignID').val(campaignID);

            $('#ddlCampaigns2').val($('#ddlCampaigns').val());
            //call httpost
            $('#ddlLobs')
              .find('option')
              .remove()
              .end()
              .append('<option value="0" selected>[Select LoB]</option>')
              .val('whatever');

            $('#ddlLobs2')
                .find('option')
                .remove()
                .end()
                .append('<option value="0" selected>[Select LoB]</option>')
                .val('whatever');

            $.post(campaignChangeURL, { "siteID": siteID,"campaignID": campaignID }, function (data) {
                $.each(data, function (index, value) {
                    $('#ddlLobs').append($('<option>', { value: value.ID, text: value.Name }));
                    $('#ddlLobs2').append($('<option>', { value: value.ID, text: value.Name }));
                    
                });
            }, 'json');
        });
    },
    OnDateClick: function (datevalue,loadUrl) {
        var selectedSite = $('#ddlSites').val();
        var selectedCampaign = $('#ddlCampaigns').val();
        var selectedLob = $('#ddlLobs').val();

        $('#IsUpdate').val('1');
        $('#datepicker').val(datevalue);
        $('#ddlSites2').prop('disabled',true);
        $('#ddlCampaigns2').prop('disabled', true);
        $('#ddlLobs2').prop('disabled', true);

     

        $.post(loadUrl, { "date": datevalue, "campaignID": selectedCampaign, "lobID": selectedLob }, function (data) {
            var txtnames = '';
            $.each(data, function (index,value) {
                var datapointID = value.DatapointID;
                var datapointValue = value.Data;

                var txtname = '#txt_' + datapointID;
                txtnames += txtname + ',';
                ////alert(txtname)
                $(txtname).val(datapointValue);
            });
            //$('#txtNames').val(txtnames.substring(0, txtnames.length - 1));

            //widget
            $('#divWidgetBody').show();
            $('#divWidgetBox').attr('class', 'widget-box');
            $('#iIcon').attr('class', 'ace-icon fa fa-chevron-up');
        }, 'json');

    },
    ClearData: function () {
        $('#IsUpdate').val('0');
        $('#ddlSites2').prop('disabled', false);
        $('#ddlCampaigns2').prop('disabled', false);
        $('#ddlLobs2').prop('disabled', false);
        $('#ddlSites2').val('0');
        $('#ddlLobs2')
                .find('option')
                .remove()
                .end()
                .append('<option value="0" selected>[Select LoB]</option>')
                .val('whatever');
        $('#ddlLobs2').val('0');
        $('#ddlCampaigns2')
               .find('option')
               .remove()
               .end()
               .append('<option value="0" selected>[Select Campaign]</option>')
               .val('whatever');
        $('#ddlCampaigns2').val('0');
        $('#datepicker').val('');

        //clear txtboxes
        if($('#txtNames').val().trim() != '')
        {
            var arrName = $('#txtNames').val().trim().split(',');
            for (var i = 0; i < arrName.length; i++) {
                $(arrName[i]).val('');
            }
            //$('#txtNames').val('');
        }
    },
    OnCancel: function () {
        $('#btnCancel').click(function () {
            ahcManagement.ClearData();
        });
        $('#btnCancel2').click(function () {
            ahcManagement.ClearData();
        });
    },
    TrainingNestingProductionDate: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            $('#txt_88' + datearray[i]).datepicker({
                showOtherMonths: true,
                selectOtherMonths: false,
                dateFormat: 'mm/dd/yy'
            }).mask('99/99/9999');
            $('#txt_89' + datearray[i]).datepicker({
                showOtherMonths: true,
                selectOtherMonths: false,
                dateFormat: 'mm/dd/yy'
            }).mask('99/99/9999');
            $('#txt_90' + datearray[i]).datepicker({
                showOtherMonths: true,
                selectOtherMonths: false,
                dateFormat: 'mm/dd/yy'
            }).mask('99/99/9999');
        });
    },
    DateRangeFilters: function(){
        var mindate = common.AddDays(common.GetMonday(), -7);
        //alert(mindate)
        $("#txtStart").datepicker({
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: 'yy-mm-dd',
            minDate: mindate,
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
            minDate: mindate,
            beforeShowDay: function (date) {
                if (date.getDay() == 1) {
                    return [true, ''];
                }
                return [false, ''];
            }
        }).mask("9999-99-99");
    },      
    Pickdate: function () {
        var mindate = common.AddDays(common.GetMonday(),-7);
        $("#datepicker").datepicker({
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: 'yy-mm-dd',
            minDate: mindate,
            beforeShowDay: function (date) {
                if (date.getDay() == 1 ) {
                    return [true, ''];
                }
                return [false, ''];
            }
            //isRTL:true,


            /*
            changeMonth: true,
            changeYear: true,
            
            showButtonPanel: true,
            beforeShow: function() {
                //change button colors
                var datepicker = $(this).datepicker( "widget" );
                setTimeout(function(){
                    var buttons = datepicker.find('.ui-datepicker-buttonpane')
                    .find('button');
                    buttons.eq(0).addClass('btn btn-xs');
                    buttons.eq(1).addClass('btn btn-xs btn-success');
                    buttons.wrapInner('<span class="bigger-110" />');
                }, 0);
            }
    */
        }).mask("9999-99-99");
    },
    OnSave: function (saveUrl) {
        var isUpdate = $('#IsUpdate').val();
    },
    ComputeNewCapacityHireScaleupsAndAttritionClassBackfill: function (date) {
        var datearray = $('#txtDates').val().trim().split(',');
        //$.each(datearray, function (i) {
            $('#txt_13' + date).val($('#txt_82' + date).val().trim());//Production HC
            $('#txt_70' + date).val($('#txt_82' + date).val().trim());//Production Total
            $('#txt_80' + date).val($('#txt_82' + date).val().trim());//Production - Site


            var a = 0;
            var b = 0;
            var newhireclasses = 0;
            var week3Nesting = 0;
            var txt_80 = 0;
            var site1 = 0;
            var prodTotal = 0;
            var nestingTotal = 0;
            var trainingTotal = 0;
            var totalHC = 0;
            var nonBillableHC = 0;
            var billableHC = 0;
            var prodNesting = 0;
            var actualProdAttrition = 0;
            var actualAttriction = 0;
            var prodSite = 0;
            var forcastedProductionAttrition = 0;
            var prodActualToForcated = 0;
            var actualAttrition = 0;
            var actualNestingAttrition = 0;
            var forecastedNestingAttrition = 0;
            var actualTrainingAttrition = 0;
            var actualAttrition104 = 0;
            var trainingActualToForecastedperc = 0;
            var forcastedTrainingAttrition = 0;
            var actualTLCount = 0;
            var actualYogiCount = 0;
            var actualSMECount = 0;
            var totalSupportCount = 0;
            var requiredTLHEadcount = 0;
            var teamLeader = 0;
            var wfmRecommendedTLHiring = 0;
            var requiredYogisHeadcount = 0;
            var yogis = 0;
            var wfmRequiredYogisHiring = 0;
            var requiredSMEHeadcount = 0;
            var smes = 0;
            var wfmRecommendedSMEHiring = 0;

            if ($('#txt_92' + date).val().trim() != '')
                a = parseFloat($('#txt_92' + date).val().trim());

            if ($('#txt_93' + date).val().trim() != '')
                b = parseFloat($('#txt_93' + date).val().trim());



            newhireclasses = a + b;
            $('#txt_15' + date).val(newhireclasses);//Training HC
            $('#txt_72' + date).val(newhireclasses);//Training Total
            $('#txt_83' + date).val(newhireclasses);//Week 3- Nesting
            $('#txt_84' + date).val(newhireclasses);//Week 2 - Nesting
            $('#txt_85' + date).val(newhireclasses);//Week 1 - Nesting
            $('#txt_86' + date).val(newhireclasses);//Training - Site
            $('#txt_87' + date).val(newhireclasses);//Wk 1 - Training
            $('#txt_91' + date).val(newhireclasses);//New Hire Classes



            week3Nesting = newhireclasses * 3;

            $('#txt_81' + date).val(week3Nesting);//Nesting - Site
            $('#txt_71' + date).val(week3Nesting);//Nesting Total
            $('#txt_14' + date).val(week3Nesting);//Nesting HC


            if ($('#txt_80' + date).val().trim() != '')
                txt_80 = parseFloat($('#txt_80' + date).val().trim());



            site1 = txt_80 + week3Nesting + newhireclasses
            $('#txt_79' + date).val(site1);


            if ($('#txt_70' + date).val().trim() != '')
                prodTotal = parseFloat($('#txt_70' + date).val().trim());
            if ($('#txt_71' + date).val().trim() != '')
                nestingTotal = parseFloat($('#txt_71' + date).val().trim());
            if ($('#txt_72' + date).val().trim() != '')
                trainingTotal = parseFloat($('#txt_72' + date).val().trim());

            totalHC = prodTotal + nestingTotal + trainingTotal;
            if (isNaN(totalHC) || !isFinite(totalHC))
                totalHC = 0;

            $('#txt_66' + date).val(totalHC);//HEADCOUNT>Overview>Total Headcount


            //HEADCOUNT>Overview>Non-Billable HC Computation

            if ($('#txt_67' + date).val().trim() != '')
                billableHC = parseFloat($('#txt_67' + date).val().trim());

            nonBillableHC = totalHC - billableHC;
            if (isNaN(nonBillableHC) || !isFinite(nonBillableHC))
                nonBillableHC = 0;

            $('#txt_68' + date).val(nonBillableHC);//HEADCOUNT>Overview>Non-Billable HC

            prodNesting = prodTotal + nestingTotal;
            if (isNaN(prodNesting) || !isFinite(prodNesting))
                prodNesting = 0;
            $('#txt_69' + date).val(prodNesting);//HEADCOUNT>Overview>Production + Nesting


            //*****************************************
            //HEADCOUNT>Attrition>Actual Prod Attrition
            //*****************************************

            if ($('#txt_76' + date).val().trim() != '') {
                if ($('#txt_80' + date).val().trim() != '')
                    prodSite = parseFloat($('#txt_80' + date).val().trim());
                if ($('#txt_96' + date).val().trim() != '')
                    actualAttriction = parseFloat($('#txt_96' + date).val().trim());

                actualProdAttrition = actualAttriction / prodSite;
            }

            if (isNaN(actualProdAttrition) || !isFinite(actualProdAttrition))
                actualProdAttrition = 0;
            $('#txt_95' + date).val(actualProdAttrition.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>Actual Prod Attrition   END
            //*****************************************

            //*****************************************
            //HEADCOUNT>Attrition>Prod - Actual to Forecasted %
            //*****************************************

            if ($('#txt_94' + date).val().trim() != '')
                forcastedProductionAttrition = parseFloat($('#txt_94' + date).val().trim());


            prodActualToForcated = actualProdAttrition / forcastedProductionAttrition;
            if (isNaN(prodActualToForcated) || !isFinite(prodActualToForcated))
                prodActualToForcated = 0;

            $('#txt_97' + date).val(prodActualToForcated.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>Prod - Actual to Forecasted %  END
            //*****************************************

            //*****************************************
            //HEADCOUNT>Attrition>Prod - Actual Nesting Attrition
            //*****************************************

            if ($('#txt_100' + date).val().trim() != '')
                actualAttrition = parseFloat($('#txt_100' + date).val().trim());



            actualNestingAttrition = actualAttrition / prodSite;
            if (isNaN(actualNestingAttrition) || !isFinite(actualNestingAttrition))
                actualNestingAttrition = 0;

            $('#txt_99' + date).val(actualNestingAttrition.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>Prod - Actual Nesting Attrition   END
            //*****************************************



            //*****************************************
            //HEADCOUNT>Attrition>NEsting - Actual to Forecasted %  
            //*****************************************


            if ($('#txt_98' + date).val().trim() != '')
                forecastedNestingAttrition = parseFloat($('#txt_98' + date).val().trim());

            var nestingActualToForecasted = actualNestingAttrition / forecastedNestingAttrition
            if (isNaN(nestingActualToForecasted) || !isFinite(nestingActualToForecasted))
                nestingActualToForecasted = 0;

            $('#txt_101' + date).val(nestingActualToForecasted.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>NEsting - Actual to Forecasted %  END
            //*****************************************


            //*****************************************
            //HEADCOUNT>Attrition>Actual Training Attrition  END
            //*****************************************


            if (newhireclasses > 0) {
                if ($('#txt_104' + date).val().trim() != '')
                    actualAttrition104 = parseFloat($('#txt_104' + date).val().trim());
            }

            actualTrainingAttrition = actualAttrition104 / newhireclasses;
            if (isNaN(actualTrainingAttrition) || !isFinite(actualTrainingAttrition))
                actualTrainingAttrition = 0;

            $('#txt_103' + date).val(actualTrainingAttrition.toFixed(2) + ' %');

            //*****************************************
            //HEADCOUNT>Attrition>Actual Training Attrition  END
            //*****************************************


            //*****************************************
            //HEADCOUNT>Attrition>Training - Actual to Forecasted %
            //*****************************************

            if ($('#txt_102' + date).val().trim() != '')
                forcastedTrainingAttrition = parseFloat($('#txt_102' + date).val().trim());

            trainingActualToForecastedperc = actualTrainingAttrition / forcastedTrainingAttrition;
            if (isNaN(actualTrainingAttrition) || !isFinite(trainingActualToForecastedperc))
                trainingActualToForecastedperc = 0;

            $('#txt_105' + date).val(trainingActualToForecastedperc.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>Training - Actual to Forecasted %  END
            //*****************************************



            if ($('#txt_107' + date).val().trim() != '')
                actualTLCount = parseFloat($('#txt_107' + date).val().trim());
            if ($('#txt_110' + date).val().trim() != '')
                actualYogiCount = parseFloat($('#txt_110' + date).val().trim());
            if ($('#txt_113' + date).val().trim() != '')
                actualSMECount = parseFloat($('#txt_113' + date).val().trim());

            totalSupportCount = actualTLCount + actualYogiCount + actualSMECount;
            if (isNaN(totalSupportCount) || !isFinite(totalSupportCount))
                totalSupportCount = 0;
            $('#txt_106' + date).val(totalSupportCount.toFixed(2));//TOTAL SUPPORT COUNT


            if ($('#txt_62' + date).val().trim() != '')
                teamLeader = parseFloat($('#txt_62' + date).val().trim());

            requiredTLHEadcount = prodTotal / teamLeader
            if (isNaN(requiredTLHEadcount) || !isFinite(requiredTLHEadcount))
                requiredTLHEadcount = 0;
            $('#txt_108' + date).val(requiredTLHEadcount.toFixed(2));//Required TL HEadcount


            wfmRecommendedTLHiring = requiredTLHEadcount - actualTLCount;
            if (isNaN(wfmRecommendedTLHiring) || !isFinite(wfmRecommendedTLHiring))
                wfmRecommendedTLHiring = 0;

            $('#txt_109' + date).val(wfmRecommendedTLHiring.toFixed(2));//WFM Recommended TL Hiring


            //Required Yogis Headcount


            if ($('#txt_64' + date).val().trim() != '')
                yogis = parseFloat($('#txt_64' + date).val().trim());

            requiredYogisHeadcount = prodTotal / yogis;
            if (isNaN(requiredYogisHeadcount) || !isFinite(requiredYogisHeadcount))
                requiredYogisHeadcount = 0;

            $('#txt_111' + date).val(requiredYogisHeadcount.toFixed(2));//Required Yogis Headcount



            wfmRequiredYogisHiring = requiredYogisHeadcount - actualYogiCount;
            if (isNaN(wfmRequiredYogisHiring) || !isFinite(wfmRequiredYogisHiring))
                wfmRequiredYogisHiring = 0;

            $('#txt_112' + date).val(wfmRequiredYogisHiring.toFixed(2));//WFM Recommended Yogis Hiring



            if ($('#txt_63' + date).val().trim() != '')
                smes = parseFloat($('#txt_63' + date).val().trim());
            requiredSMEHeadcount = prodTotal / smes;
            if (isNaN(requiredSMEHeadcount) || !isFinite(requiredSMEHeadcount))
                requiredSMEHeadcount = 0;
            $('#txt_114' + date).val(requiredSMEHeadcount.toFixed(2));//Required SME Headcount




            wfmRecommendedSMEHiring = requiredSMEHeadcount - actualSMECount;
            if (isNaN(wfmRecommendedSMEHiring) || !isFinite(wfmRecommendedSMEHiring))
                wfmRecommendedSMEHiring = 0;
            $('#txt_115' + date).val(wfmRecommendedSMEHiring.toFixed(2));//WFM Recommended SME Hiring
        //});
    },
    OnButtonDatesChange: function(){
        $('#txtStart').bind('propertychange change keyup paste input', function () {
            $('#btnSave').hide();
        });
        $('#txtEnd').bind('propertychange change keyup paste input', function () {
            $('#btnSave').hide();
        });
    },
    OnKeyup: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            $('#txt_82' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillStatic(datearray[i], '#txt_82');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });

            $('#txt_7' + datearray[i]).bind('propertychange change keyup paste input', function () {
                $('#txt_16' + datearray[i]).val($('#txt_7' + datearray[i]).val().trim());//Support HC
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_7');
            });
            $('#txt_62' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_92' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_92');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });

            $('#txt_93' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_93');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_94' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_94');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_96' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_96');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_98' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_98');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_62' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillStatic(datearray[i], '#txt_62');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_63' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillStatic(datearray[i], '#txt_63');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_64' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillStatic(datearray[i], '#txt_64');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_67' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillStatic(datearray[i], '#txt_67');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_76' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_76');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_100' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_100');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_102' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_102');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_104' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic(datearray[i], '#txt_104');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_107' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillStatic(datearray[i], '#txt_107');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_110' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillStatic(datearray[i], '#txt_110');
                //ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });
            $('#txt_113' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            });

            $('#txt_10' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeGoalToTargetAHT(datearray[i],'#txt_10');
                //ahcManagement.ComputeGoalToTargetAHT();
            });

            $('#txt_11' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeGoalToTargetAHT(datearray[i],'#txt_11');
                //ahcManagement.ComputeGoalToTargetAHT();
            });


            $('#txt_88' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeTrainingDates(datearray[i], '#txt_88');
            });
            $('#txt_89' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeTrainingDates(datearray[i], '#txt_89');
            });
            $('#txt_90' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeTrainingDates(datearray[i], '#txt_90');
            });

          
            //horizontal cascade (STATIC)
            $('#txt_1' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalStatic(datearray[i], '#txt_1');
            });
            $('#txt_9' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalStatic(datearray[i], '#txt_9');
            });
            $('#txt_54' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalStatic(datearray[i], '#txt_54');
            });
            $('#txt_56' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalStatic(datearray[i], '#txt_56');
            });
            $('#txt_57' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalStatic(datearray[i], '#txt_57');
            });
            $('#txt_61' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalStatic(datearray[i], '#txt_61');
            });
            $('#txt_65' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalStatic(datearray[i], '#txt_65');
            });

            //horizontal cascade (DYNAMIC)
            $('#txt_2' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_2');
            });
            $('#txt_3' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_3');
            });
            $('#txt_4' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_4');
            });
            $('#txt_5' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_5');
            });
            $('#txt_6' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_6');
            });
            $('#txt_8' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_8');
            });
            $('#txt_55' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_55');
            });
            $('#txt_58' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_58');
            });
            $('#txt_59' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_59');
            });
            $('#txt_60' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_60');
            });
            $('#txt_73' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_73');
            });
            $('#txt_74' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_74');
            });
            $('#txt_75' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_75');
            });
            $('#txt_77' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_77');
            });
            $('#txt_78' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_78');
            });
            $('#txt_116' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_116');
            });
            $('#txt_117' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.CascadeHorizontalDynamic(datearray[i], '#txt_117');
            });
        });
    },
    CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillStatic: function (datetoremove, txtname) {
        var datearray = $('#txtDates').val().trim().replace(datetoremove, '').replace(',,', ',').split(',');
        var datetoremovearray = datetoremove.replace('_', '').split('x');

        var prevDate = new Date(datetoremovearray[0], (parseInt(datetoremovearray[1]) - 1), datetoremovearray[2]);

        ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datetoremove);
        //var prevValue = $(txtname + datetoremove).val();
        $.each(datearray, function (i) {
            var datesplit = datearray[i].replace('_', '').split('x');
            var date = new Date(datesplit[0], (parseInt(datesplit[1]) - 1), datesplit[2]);
            var prevValue = $(txtname + datetoremove).val();

            if ((date > prevDate) == true) {
                $(txtname + datearray[i]).val(prevValue);
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            }
        });
    },
    CascadeHorizontalNewCapacityHireScaleupsAndAttritionClassBackfillDynamic: function (datetoremove, txtname) {
        var datearray = $('#txtDates').val().trim().replace(datetoremove, '').replace(',,', ',').split(',');
        var datetoremovearray = datetoremove.replace('_', '').split('x');

        var prevDate = new Date(datetoremovearray[0], (parseInt(datetoremovearray[1]) - 1), datetoremovearray[2]);

        ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datetoremove);
        //var prevValue = $(txtname + datetoremove).val();
        $.each(datearray, function (i) {
            var datesplit = datearray[i].replace('_', '').split('x');
            var date = new Date(datesplit[0], (parseInt(datesplit[1]) - 1), datesplit[2]);
            //var prevValue = $(txtname + datetoremove).val();

            if ((date > prevDate) == true) {
                //commented_04272018 $(txtname + datearray[i]).val('');
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill(datearray[i]);
            }
        });
    },
    CascadeHorizontalStatic: function (datetoremove, txtname) {
        var datearray = $('#txtDates').val().trim().replace(datetoremove, '').replace(',,', ',').split(',');
        var datetoremovearray = datetoremove.replace('_', '').split('x');

        var prevDate = new Date(datetoremovearray[0], (parseInt(datetoremovearray[1]) - 1), datetoremovearray[2]);
        var prevValue = $(txtname + datetoremove).val();
        $.each(datearray, function (i) {
            var datesplit = datearray[i].replace('_', '').split('x');
            var date = new Date(datesplit[0], (parseInt(datesplit[1]) - 1), datesplit[2]);
            var prevValue = $(txtname + datetoremove).val();

            if ((date > prevDate) === true) {
                $(txtname + datearray[i]).val(prevValue);
               
            }
        });
    },
    CascadeHorizontalDynamic: function (datetoremove, txtname) {
        var datearray = $('#txtDates').val().trim().replace(datetoremove, '').replace(',,', ',').split(',');
        var datetoremovearray = datetoremove.replace('_', '').split('x');

        var prevDate = new Date(datetoremovearray[0], (parseInt(datetoremovearray[1]) - 1), datetoremovearray[2]);
        var prevValue = $(txtname + datetoremove).val();
     
        $.each(datearray, function (i) {
            var datesplit = datearray[i].replace('_', '').split('x');
            var date = new Date(datesplit[0], (parseInt(datesplit[1]) - 1), datesplit[2]);
                  
         

            if ((date > prevDate) === true) {
                //commented_04272018 $(txtname + datearray[i]).val('');
                if (txtname == '#txt_7') {
                    $('#txt_16' + datearray[i]).val($(txtname + datearray[i]).val().trim());
                }
            }
        });
    },
    CascadeTrainingDates: function(datetoremove,txtname){
        var datearray = $('#txtDates').val().trim().replace(datetoremove, '').replace(',,', ',').split(',');
        var datetoremovearray = datetoremove.replace('_', '').split('x');

        var prevDate = new Date(datetoremovearray[0], (parseInt(datetoremovearray[1]) - 1), datetoremovearray[2]);
        var prevValue = $(txtname + datetoremove).val();
        $.each(datearray, function (i) {
            var datesplit = datearray[i].replace('_', '').split('x');
            var date = new Date(datesplit[0], (parseInt(datesplit[1]) - 1), datesplit[2]);
           
            if ((date > prevDate) === true) {
                //commented_04272018 $(txtname + datearray[i]).val('');
            }
        });
    },
    OnFocus: function () {
        var dateArray = $('#txtDates').val().trim().split(',');
        if (dateArray != '') {
            var inputNameArray = $('#txtInputtedNames').val().split(',');

            $.each(dateArray, function (i) {
                $.each(inputNameArray, function (j) {
                    var txtname = inputNameArray[j] + dateArray[i];
                    $(txtname).bind('focus', function () {
                        $(this).val('');
                    });
                });
            });
        }
    },
    CascadeGoalToTargetAHT: function (datetoremove, txtname) {
        var datearray = $('#txtDates').val().trim().replace(datetoremove, '').replace(',,', ',').split(',');
        var datetoremovearray = datetoremove.replace('_', '').split('x');

        var prevDate = new Date(datetoremovearray[0], (parseInt(datetoremovearray[1]) - 1), datetoremovearray[2]);
        var prevValue = $(txtname + datetoremove).val();

        $.each(datearray, function (i) {
            var datesplit = datearray[i].replace('_', '').split('x');
            var date = new Date(datesplit[0], (parseInt(datesplit[1]) - 1), datesplit[2]);

            ahcManagement.ComputeGoalToTargetAHT();

            if ((date > prevDate) === true) {
                //commented_04272018 $(txtname + datearray[i]).val('');
            }
        });
    },
    ComputeGoalToTargetAHT: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            var projectedAHT = 0;
            var actualAHT = 0;
            if ($('#txt_10' + datearray[i]).val().trim() != '')
                projectedAHT = parseFloat($('#txt_10' + datearray[i]).val().trim());
            if ($('#txt_11' + datearray[i]).val().trim() != '')
                actualAHT = parseFloat($('#txt_11' + datearray[i]).val().trim());

            var value = projectedAHT / actualAHT;
            //alert( isFinite( value ))

            if (isNaN(value) || !isFinite(value))
                value = 0;

            $('#txt_12' + datearray[i]).val(value.toFixed(2) + ' %');
        });
    },

    CascadeShrinkage: function (datetoremove,txtname,shrinkagecomputation) {
        //remove the current date
        var datearray = $('#txtDates').val().trim().replace(datetoremove, '').replace(',,', ',').split(',');
        var datetoremovearray = datetoremove.replace('_', '').split('x');
        var prevDate = new Date(datetoremovearray[0], (parseInt( datetoremovearray[1] )- 1), datetoremovearray[2]);
        var prevValue = $(txtname + datetoremove).val();
        //mm-dd-yyyy

        $.each(datearray, function (i) {
            //datearray must be > [datetoremove] value
            
            var datesplit = datearray[i].replace('_', '').split('x');
            var date = new Date(datesplit[0], (parseInt(datesplit[1]) - 1), datesplit[2]);
           
            if((date > prevDate) === true)
            {               
                switch (shrinkagecomputation) {
                    case "1":
                        //static
                        $(txtname + datearray[i]).val(prevValue);
                        ahcManagement.ComputeProjectedProductionShrinkage(datearray[i]);
                        break;
                    case "2":
                        //static
                        $(txtname + datearray[i]).val(prevValue);
                        ahcManagement.ComputeProjectedNestingShrinkage(datearray[i]);
                        break;
                    case "3":
                       //dynamic
                        //commented_04272018 $(txtname + datearray[i]).val('');
                        ahcManagement.ComputeActualProductionShrinkage(datearray[i]);
                        break;
                    case "4":
                        //dynamic
                        //commented_04272018 $(txtname + datearray[i]).val('');
                        ahcManagement.ComputeActualNestingShrinkage(datearray[i]);
                        break;
                }                
            }
        });
    },
    ComputeProjectedProductionShrinkage: function (date) {
        //var datearray = $('#txtDates').val().trim().split(',');
        //$.each(datearray, function (i) {

            var a = 0;
            var b = 0;
            var c = 0;
            var d = 0;

            if ($('#txt_19' + date).val().trim() != '')//Breaks
                a = parseFloat($('#txt_19' + date).val().trim());
            if ($('#txt_20' + date).val().trim() != '')//Coaching + Meeting + Training
                b = parseFloat($('#txt_20' + date).val().trim());
            if ($('#txt_21' + date).val().trim() != '')//System Down Time
                c = parseFloat($('#txt_21' + date).val().trim());
            if ($('#txt_22' + date).val().trim() != '')//Lost Hours
                d = parseFloat($('#txt_22' + date).val().trim());

            var sum = a + b + c + d;
            $('#txt_18' + date).val(sum);//In-center Shrinkage

            var unplanned = 0;
            var planned = 0;
            if ($('#txt_24' + date).val().trim() != '')//Unplanned
                unplanned = parseFloat($('#txt_24' + date).val().trim());
            if ($('#txt_25' + date).val().trim() != '')//Planned
                planned = parseFloat($('#txt_25' + date).val().trim());

            var sumOfPlannedUnplanned = unplanned + planned;

            $('#txt_23' + date).val(sumOfPlannedUnplanned);//Out-of center Shrinkage
            $('#txt_17' + date).val(sum + sumOfPlannedUnplanned);//Overall Projected Production Shrinkage
            ahcManagement.ComputeShrinkageVariance(date, parseFloat($('#txt_35' + date).val()), parseFloat($('#txt_44' + date).val()), parseFloat($('#txt_17' + date).val()), parseFloat($('#txt_26' + date).val()));

        //});
    },//1
    OnKeyupProjectedProductionShrinkage: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            //START ProjectedProductionShrinkage
            //Breaks    
            $('#txt_19' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_19', '1');
            });
            //Coaching + Meeting + Training
            $('#txt_20' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_20', '1');
            });
            //System Down Time
            $('#txt_21' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_21', '1');
            });
            //Lost Hours
            $('#txt_22' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_22', '1');
            });
            //Unplanned
            $('#txt_24' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_24', '1');
            });
            //Planned
            $('#txt_25' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_25', '1');
            });
            //END ProjectedProductionShrinkage
        });
    },

    ComputeProjectedNestingShrinkage: function (date) {
        //var datearray = $('#txtDates').val().trim().split(',');
        //$.each(datearray, function (i) {

            var a = 0;
            var b = 0;
            var c = 0;
            var d = 0;

            if ($('#txt_28' + date).val().trim() != '')//Breaks
                a = parseFloat($('#txt_28' + date).val().trim());
            if ($('#txt_29' + date).val().trim() != '')//Coaching + Meeting + Training
                b = parseFloat($('#txt_29' + date).val().trim());
            if ($('#txt_30' + date).val().trim() != '')//System Down Time
                c = parseFloat($('#txt_30' + date).val().trim());
            if ($('#txt_31' + date).val().trim() != '')//Lost Hours
                d = parseFloat($('#txt_31' + date).val().trim());

            var sum = a + b + c + d;
            $('#txt_27' + date).val(sum);//In-center Shrinkage

            var unplanned = 0;
            var planned = 0;
            if ($('#txt_33' + date).val().trim() != '')//Unplanned
                unplanned = parseFloat($('#txt_33' + date).val().trim());
            if ($('#txt_34' + date).val().trim() != '')//Planned
                planned = parseFloat($('#txt_34' + date).val().trim());

            var sumOfPlannedUnplanned = unplanned + planned;

            $('#txt_32' + date).val(sumOfPlannedUnplanned);//Out-of center Shrinkage
            $('#txt_26' + date).val(sum + sumOfPlannedUnplanned);//Overall Projected Production Shrinkage
            ahcManagement.ComputeShrinkageVariance(date, parseFloat($('#txt_35' + date).val()), parseFloat($('#txt_44' + date).val()), parseFloat($('#txt_17' + date).val()), parseFloat($('#txt_26' + date).val()));
        //});
    },//2
    OnKeyupProjectedNestingShrinkage: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            //Breaks    
            $('#txt_28' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_28', '2');
            });
            //Coaching + Meeting + Training
            $('#txt_29' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_29', '2');
            });
            //System Down Time
            $('#txt_30' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_30', '2');
            });
            //Lost Hours
            $('#txt_31' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_31', '2');
            });
            //Unplanned
            $('#txt_33' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_33', '2');
            });
            //Planned
            $('#txt_34' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_34', '2');
            });
        });
    },

    ComputeActualProductionShrinkage: function (date) {
        //var datearray = $('#txtDates').val().trim().split(',');
        //$.each(datearray, function (i) {

            var a = 0;
            var b = 0;
            var c = 0;
            var d = 0;

            if ($('#txt_37' + date).val().trim() != '')//Breaks
                a = parseFloat($('#txt_37' + date).val().trim());
            if ($('#txt_38' + date).val().trim() != '')//Coaching + Meeting + Training
                b = parseFloat($('#txt_38' + date).val().trim());
            if ($('#txt_39' + date).val().trim() != '')//System Down Time
                c = parseFloat($('#txt_39' + date).val().trim());
            if ($('#txt_40' + date).val().trim() != '')//Lost Hours
                d = parseFloat($('#txt_40' + date).val().trim());

            var sum = a + b + c + d;
            $('#txt_36' + date).val(sum);//In-center Shrinkage

            var unplanned = 0;
            var planned = 0;
            if ($('#txt_42' + date).val().trim() != '')//Unplanned
                unplanned = parseFloat($('#txt_42' + date).val().trim());
            if ($('#txt_43' + date).val().trim() != '')//Planned
                planned = parseFloat($('#txt_43' + date).val().trim());

            var sumOfPlannedUnplanned = unplanned + planned;

            $('#txt_41' + date).val(sumOfPlannedUnplanned);//Out-of center Shrinkage
            $('#txt_35' + date).val(sum + sumOfPlannedUnplanned);//Overall Actual Production Shrinkage
            ahcManagement.ComputeShrinkageVariance(date, parseFloat($('#txt_35' + date).val()), parseFloat($('#txt_44' + date).val()), parseFloat($('#txt_17' + date).val()), parseFloat($('#txt_26' + date).val()));
        //});
    },//3
    OnKeyupActualProductionShrinkage: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            //Breaks    
            $('#txt_37' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_37', '3');
            });
            //Coaching + Meeting + Training
            $('#txt_38' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_38', '3');
            });
            //System Down Time
            $('#txt_39' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_39', '3');
            });
            //Lost Hours
            $('#txt_40' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_40', '3');
            });
            //Unplanned
            $('#txt_42' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_42', '3');
            });
            //Planned
            $('#txt_43' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_43', '3');
            });
        });
    },

    ComputeActualNestingShrinkage: function (date) {
        //var datearray = $('#txtDates').val().trim().split(',');
        //$.each(datearray, function (i) {

            var a = 0;
            var b = 0;
            var c = 0;
            var d = 0;

            if ($('#txt_46' + date).val().trim() != '')//Breaks
                a = parseFloat($('#txt_46' + date).val().trim());
            if ($('#txt_47' + date).val().trim() != '')//Coaching + Meeting + Training
                b = parseFloat($('#txt_47' + date).val().trim());
            if ($('#txt_48' + date).val().trim() != '')//System Down Time
                c = parseFloat($('#txt_48' + date).val().trim());
            if ($('#txt_49' + date).val().trim() != '')//Lost Hours
                d = parseFloat($('#txt_49' + date).val().trim());

            var sum = a + b + c + d;
            $('#txt_45' + date).val(sum);//In-center Shrinkage

            var unplanned = 0;
            var planned = 0;
            if ($('#txt_51' + date).val().trim() != '')//Unplanned
                unplanned = parseFloat($('#txt_51' + date).val().trim());
            if ($('#txt_52' + date).val().trim() != '')//Planned
                planned = parseFloat($('#txt_52' + date).val().trim());

            var sumOfPlannedUnplanned = unplanned + planned;

            $('#txt_50' + date).val(sumOfPlannedUnplanned);//Out-of center Shrinkage
            $('#txt_44' + date).val(sum + sumOfPlannedUnplanned);//Overall Actual Nesting Shrinkage
            ahcManagement.ComputeShrinkageVariance(date, parseFloat($('#txt_35' + date).val()), parseFloat($('#txt_44' + date).val()), parseFloat($('#txt_17' + date).val()), parseFloat($('#txt_26' + date).val()));
        //});
    },//4
    OnKeyupActualNestingShrinkage: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            //Breaks    
            $('#txt_46' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_46', '4');
            });
            //Coaching + Meeting + Training
            $('#txt_47' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_47', '4');
            });
            //System Down Time
            $('#txt_48' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_48', '4');
            });
            //Lost Hours
            $('#txt_49' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_49', '4');
            });
            //Unplanned
            $('#txt_51' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_51', '4');
            });
            //Planned
            $('#txt_52' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage(datearray[i]);
                ahcManagement.CascadeShrinkage(datearray[i], '#txt_52', '4');
            });
        });
    },

    ComputeShrinkageVariance: function (datearrayvalue, txt_35, txt_44, txt_17, txt_26) {
        var variance = ((txt_35 + txt_44) - (txt_17 + txt_26));
        if (isNaN(variance) || !isFinite(variance))
            variance = 0;

        $('#txt_53' + datearrayvalue).val(variance.toFixed(2) + ' %');
    },
    Save: function (url) {
        $('#btnSave').click(function () {
            var foundin = $('td:contains("Data is not available.")').length > 0;
            //alert(foundin)
            if (foundin == false) {
                $.confirm({
                    closeIcon: true,
                    title: 'WFMPCP | AHC Manager',
                    content: 'Save data?',
                    confirmButton: 'Yes',
                    cancelButton: 'No',
                    confirm: function () {
                        $('#divLoading').show();
                        ahcManagement.SaveData(url);
                    }
                });
            }
            else {
                $.alert({
                    closeIcon: true,
                    title: 'WFMPCP | AHC Manager',
                    content: "No data to save."
                });
            }
        });
        $('#btnSave2').click(function () {
            ahcManagement.SaveData(url);
        });
    },
    SaveData: function (url) {
        var txtnames = $('#txtNames').val().split(',');
        var datapointIDs = '';
        var datapointValues ='';
        var campaignID = $('#ddlCampaigns').val();
        var siteID = $('#ddlSites').val();
        var lobID = $('#ddlLobs').val();
        var date = $('#datepicker').val();
        
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            txtnames.forEach(function (txtname) {
                //datapointIDs += txtname.replace('#txt_', '') + ',';
                datapointValues += txtname.replace('#txt_', (datearray[i].replace('_','') + '_')) + ':' + $(txtname + datearray[i]).val() + ',';
            });
        });

        var data = {
            //"datapointIds" : datapointIDs,
            "datapointValues": datapointValues,
            "date": date,
            "campaignID": campaignID,
            "lobID": lobID,
            "siteID": siteID
        };
        $.post(url, data, function (data) {
            $('#divLoading').hide();
            $.alert({
                closeIcon: true,
                title: 'WFMPCP | AHC Manager',
                content: data.Message
            });
            
            ahcManagement.ClearData();
        }, 'json');
    }
}