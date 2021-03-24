var ahcManagement = {
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
            //$('#divLoading').show();
            return true;
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
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            //PCP input
            $('#txt_1' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_1');
            });
            $('#txt_2' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_2');
            });
            $('#txt_3' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_3');
            });
            $('#txt_4' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_4');
            });
            $('#txt_5' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_5');
            });
            $('#txt_6' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_6');
            });
            $('#txt_7' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_7');
            });
            $('#txt_8' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_8');
            });
            $('#txt_9' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_9');
            });
            $('#txt_10' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_10');
            });
            $('#txt_11' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_11');
            });
            $('#txt_19' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_19');
            });
            $('#txt_20' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_20');
            });
            $('#txt_21' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_21');
            });
            $('#txt_22' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_22');
            });
            $('#txt_24' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_24');
            });
            $('#txt_25' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_25');
            });
            $('#txt_28' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_28');
            });
            $('#txt_29' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_29');
            });
            $('#txt_30' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_30');
            });
            $('#txt_31' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_31');
            });
            $('#txt_33' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_33');
            });
            $('#txt_34' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_34');
            });
            $('#txt_37' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_37');
            });
            $('#txt_38' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_38');
            });
            $('#txt_39' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_39');
            });
            $('#txt_40' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_40');
            });
            $('#txt_42' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_42');
            });
            $('#txt_43' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_43');
            });
            $('#txt_46' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_46');
            });
            $('#txt_47' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_47');
            });
            $('#txt_48' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_48');
            });
            $('#txt_49' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_49');
            });
            $('#txt_51' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_51');
            });
            $('#txt_50' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_50');
            });

            $('#txt_54' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_54');
            });
            $('#txt_55' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_55');
            });
            $('#txt_56' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_56');
            });
            $('#txt_57' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_57');
            });
            $('#txt_58' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_58');
            });
            $('#txt_59' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_59');
            });
            $('#txt_60' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_60');
            });
            $('#txt_61' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_61');
            });
            $('#txt_62' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_62');
            });
            $('#txt_63' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_63');
            });
            $('#txt_64' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_64');
            });
            $('#txt_65' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_65');
            });

            $('#txt_67' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_67');
            });
            $('#txt_73' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_73');
            });
            $('#txt_74' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_74');
            });
            $('#txt_75' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_75');
            });
            $('#txt_76' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_76');
            });
            $('#txt_77' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_77');
            });
            $('#txt_78' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_78');
            });
            $('#txt_82' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_82');
            });
            $('#txt_92' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_92');
            });
            $('#txt_93' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_93');
            });
            $('#txt_94' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_94');
            });
            $('#txt_96' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_96');
            });
            $('#txt_98' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_98');
            });
            $('#txt_100' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_100');
            });
            $('#txt_102' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowFloat(event, '#txt_102');
            });
            $('#txt_104' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_104');
            });
            $('#txt_107' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_107');
            });
            $('#txt_110' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_110');
            });
            $('#txt_113' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_113');
            });
            $('#txt_116' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_116');
            });
            $('#txt_117' + datearray[i]).on('keypress keyup blur', function (event) {
                common.AllowInt(event, '#txt_117');
            });
        });
        
    },
    Initialize: function () {
        $('#LobID').val('0');
        $('#txtNames').hide();
        $('#IsUpdate').hide();

        ////hide widget
        //$('#divWidgetBody').hide();
        //$('#divWidgetBox').attr('class','widget-box collapsed');
        //$('#iIcon').attr('class', 'ace-icon fa fa-chevron-down');
    },    
    LobChange: function () {
        $('#ddlLobs').change(function () {
            $('#LobID').val($('#ddlLobs').val());
            $('#ddlLobs2').val($('#ddlLobs').val());
        });
    },
    SiteChange: function (siteChangeURL) {
        $('#ddlSites').change(function () {
            var siteid = $('#ddlSites').val();
            ahcManagement.Initialize();

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
            var campaignID = $('#ddlCampaigns').val();
            ahcManagement.Initialize();

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

            $.post(campaignChangeURL, { "campaignID": campaignID }, function (data) {
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

     

        $.post(loadUrl, { 'date': datevalue, 'campaignID': selectedCampaign, 'lobID': selectedLob }, function (data) {
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
                .append('<option value='0' selected>[Select LoB]</option>')
                .val('whatever');
        $('#ddlLobs2').val('0');
        $('#ddlCampaigns2')
               .find('option')
               .remove()
               .end()
               .append('<option value='0' selected>[Select Campaign]</option>')
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
    FilterDates: function () {

        var mindate = common.AddDays(common.GetMonday(), -7);

        $('#txtStart').datepicker({
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
        }).mask('9999-99-99');
        $('#txtEnd').datepicker({
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
        }).mask('9999-99-99');
    },
    Pickdate: function () {
        var mindate = common.AddDays(common.GetMonday(),-7);
        $('#datepicker').datepicker({
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
                var datepicker = $(this).datepicker( 'widget' );
                setTimeout(function(){
                    var buttons = datepicker.find('.ui-datepicker-buttonpane')
                    .find('button');
                    buttons.eq(0).addClass('btn btn-xs');
                    buttons.eq(1).addClass('btn btn-xs btn-success');
                    buttons.wrapInner('<span class='bigger-110' />');
                }, 0);
            }
    */
        }).mask('9999-99-99');
    },    
    OnSave: function (saveUrl) {
        var isUpdate = $('#IsUpdate').val();
    },
    ComputeNewCapacityHireScaleupsAndAttritionClassBackfill: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {

            $('#txt_13' + datearray[i]).val($('#txt_82' + datearray[i]).val().trim());//Production HC
            $('#txt_70' + datearray[i]).val($('#txt_82' + datearray[i]).val().trim());//Production Total
            $('#txt_80' + datearray[i]).val($('#txt_82' + datearray[i]).val().trim());//Production - Site


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

            if ($('#txt_92' + datearray[i]).val().trim() != '')
                a = parseFloat($('#txt_92' + datearray[i]).val().trim());

            if ($('#txt_93' + datearray[i]).val().trim() != '')
                b = parseFloat($('#txt_93' + datearray[i]).val().trim());



            newhireclasses = a + b;
            $('#txt_15' + datearray[i]).val(newhireclasses);//Training HC
            $('#txt_72' + datearray[i]).val(newhireclasses);//Training Total
            $('#txt_83' + datearray[i]).val(newhireclasses);//Week 3- Nesting
            $('#txt_84' + datearray[i]).val(newhireclasses);//Week 2 - Nesting
            $('#txt_85' + datearray[i]).val(newhireclasses);//Week 1 - Nesting
            $('#txt_86' + datearray[i]).val(newhireclasses);//Training - Site
            $('#txt_87' + datearray[i]).val(newhireclasses);//Wk 1 - Training
            $('#txt_91' + datearray[i]).val(newhireclasses);//New Hire Classes



            week3Nesting = newhireclasses * 3;

            $('#txt_81' + datearray[i]).val(week3Nesting);//Nesting - Site
            $('#txt_71' + datearray[i]).val(week3Nesting);//Nesting Total
            $('#txt_14' + datearray[i]).val(week3Nesting);//Nesting HC


            if ($('#txt_80' + datearray[i]).val().trim() != '')
                txt_80 = parseFloat($('#txt_80' + datearray[i]).val().trim());



            site1 = txt_80 + week3Nesting + newhireclasses
            $('#txt_79' + datearray[i]).val(site1);


            if ($('#txt_70' + datearray[i]).val().trim() != '')
                prodTotal = parseFloat($('#txt_70' + datearray[i]).val().trim());
            if ($('#txt_71' + datearray[i]).val().trim() != '')
                nestingTotal = parseFloat($('#txt_71' + datearray[i]).val().trim());
            if ($('#txt_72' + datearray[i]).val().trim() != '')
                trainingTotal = parseFloat($('#txt_72' + datearray[i]).val().trim());

            totalHC = prodTotal + nestingTotal + trainingTotal;
            if (isNaN(totalHC) || !isFinite(totalHC))
                totalHC = 0;

            $('#txt_66' + datearray[i]).val(totalHC);//HEADCOUNT>Overview>Total Headcount


            //HEADCOUNT>Overview>Non-Billable HC Computation

            if ($('#txt_67' + datearray[i]).val().trim() != '')
                billableHC = parseFloat($('#txt_67' + datearray[i]).val().trim());

            nonBillableHC = totalHC - billableHC;
            if (isNaN(nonBillableHC) || !isFinite(nonBillableHC))
                nonBillableHC = 0;

            $('#txt_68' + datearray[i]).val(nonBillableHC);//HEADCOUNT>Overview>Non-Billable HC

            prodNesting = prodTotal + nestingTotal;
            if (isNaN(prodNesting) || !isFinite(prodNesting))
                prodNesting = 0;
            $('#txt_69' + datearray[i]).val(prodNesting);//HEADCOUNT>Overview>Production + Nesting


            //*****************************************
            //HEADCOUNT>Attrition>Actual Prod Attrition
            //*****************************************

            if ($('#txt_76' + datearray[i]).val().trim() != '') {
                if ($('#txt_80' + datearray[i]).val().trim() != '')
                    prodSite = parseFloat($('#txt_80' + datearray[i]).val().trim());
                if ($('#txt_96' + datearray[i]).val().trim() != '')
                    actualAttriction = parseFloat($('#txt_96' + datearray[i]).val().trim());

                actualProdAttrition = actualAttriction / prodSite;
            }

            if (isNaN(actualProdAttrition) || !isFinite(actualProdAttrition))
                actualProdAttrition = 0;
            $('#txt_95' + datearray[i]).val(actualProdAttrition.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>Actual Prod Attrition   END
            //*****************************************

            //*****************************************
            //HEADCOUNT>Attrition>Prod - Actual to Forecasted %
            //*****************************************

            if ($('#txt_94' + datearray[i]).val().trim() != '')
                forcastedProductionAttrition = parseFloat($('#txt_94' + datearray[i]).val().trim());


            prodActualToForcated = actualProdAttrition / forcastedProductionAttrition;
            if (isNaN(prodActualToForcated) || !isFinite(prodActualToForcated))
                prodActualToForcated = 0;

            $('#txt_97' + datearray[i]).val(prodActualToForcated.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>Prod - Actual to Forecasted %  END
            //*****************************************

            //*****************************************
            //HEADCOUNT>Attrition>Prod - Actual Nesting Attrition
            //*****************************************

            if ($('#txt_100' + datearray[i]).val().trim() != '')
                actualAttrition = parseFloat($('#txt_100' + datearray[i]).val().trim());



            actualNestingAttrition = actualAttrition / prodSite;
            if (isNaN(actualNestingAttrition) || !isFinite(actualNestingAttrition))
                actualNestingAttrition = 0;

            $('#txt_99' + datearray[i]).val(actualNestingAttrition.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>Prod - Actual Nesting Attrition   END
            //*****************************************



            //*****************************************
            //HEADCOUNT>Attrition>NEsting - Actual to Forecasted %  
            //*****************************************


            if ($('#txt_98' + datearray[i]).val().trim() != '')
                forecastedNestingAttrition = parseFloat($('#txt_98' + datearray[i]).val().trim());

            var nestingActualToForecasted = actualNestingAttrition / forecastedNestingAttrition
            if (isNaN(nestingActualToForecasted) || !isFinite(nestingActualToForecasted))
                nestingActualToForecasted = 0;

            $('#txt_101' + datearray[i]).val(nestingActualToForecasted.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>NEsting - Actual to Forecasted %  END
            //*****************************************


            //*****************************************
            //HEADCOUNT>Attrition>Actual Training Attrition  END
            //*****************************************


            if (newhireclasses > 0) {
                if ($('#txt_104' + datearray[i]).val().trim() != '')
                    actualAttrition104 = parseFloat($('#txt_104' + datearray[i]).val().trim());
            }

            actualTrainingAttrition = actualAttrition104 / newhireclasses;
            if (isNaN(actualTrainingAttrition) || !isFinite(actualTrainingAttrition))
                actualTrainingAttrition = 0;

            $('#txt_103' + datearray[i]).val(actualTrainingAttrition.toFixed(2) + ' %');

            //*****************************************
            //HEADCOUNT>Attrition>Actual Training Attrition  END
            //*****************************************


            //*****************************************
            //HEADCOUNT>Attrition>Training - Actual to Forecasted %
            //*****************************************

            if ($('#txt_102' + datearray[i]).val().trim() != '')
                forcastedTrainingAttrition = parseFloat($('#txt_102' + datearray[i]).val().trim());

            trainingActualToForecastedperc = actualTrainingAttrition / forcastedTrainingAttrition;
            if (isNaN(actualTrainingAttrition) || !isFinite(trainingActualToForecastedperc))
                trainingActualToForecastedperc = 0;

            $('#txt_105' + datearray[i]).val(trainingActualToForecastedperc.toFixed(2) + ' %');
            //*****************************************
            //HEADCOUNT>Attrition>Training - Actual to Forecasted %  END
            //*****************************************



            if ($('#txt_107' + datearray[i]).val().trim() != '')
                actualTLCount = parseFloat($('#txt_107' + datearray[i]).val().trim());
            if ($('#txt_110' + datearray[i]).val().trim() != '')
                actualYogiCount = parseFloat($('#txt_110' + datearray[i]).val().trim());
            if ($('#txt_113' + datearray[i]).val().trim() != '')
                actualSMECount = parseFloat($('#txt_113' + datearray[i]).val().trim());

            totalSupportCount = actualTLCount + actualYogiCount + actualSMECount;
            if (isNaN(totalSupportCount) || !isFinite(totalSupportCount))
                totalSupportCount = 0;
            $('#txt_106' + datearray[i]).val(totalSupportCount.toFixed(2));//TOTAL SUPPORT COUNT


            if ($('#txt_62' + datearray[i]).val().trim() != '')
                teamLeader = parseFloat($('#txt_62' + datearray[i]).val().trim());

            requiredTLHEadcount = prodTotal / teamLeader
            if (isNaN(requiredTLHEadcount) || !isFinite(requiredTLHEadcount))
                requiredTLHEadcount = 0;
            $('#txt_108' + datearray[i]).val(requiredTLHEadcount.toFixed(2));//Required TL HEadcount


            wfmRecommendedTLHiring = requiredTLHEadcount - actualTLCount;
            if (isNaN(wfmRecommendedTLHiring) || !isFinite(wfmRecommendedTLHiring))
                wfmRecommendedTLHiring = 0;

            $('#txt_109' + datearray[i]).val(wfmRecommendedTLHiring.toFixed(2));//WFM Recommended TL Hiring


            //Required Yogis Headcount


            if ($('#txt_64' + datearray[i]).val().trim() != '')
                yogis = parseFloat($('#txt_64' + datearray[i]).val().trim());

            requiredYogisHeadcount = prodTotal / yogis;
            if (isNaN(requiredYogisHeadcount) || !isFinite(requiredYogisHeadcount))
                requiredYogisHeadcount = 0;

            $('#txt_111' + datearray[i]).val(requiredYogisHeadcount.toFixed(2));//Required Yogis Headcount



            wfmRequiredYogisHiring = requiredYogisHeadcount - actualYogiCount;
            if (isNaN(wfmRequiredYogisHiring) || !isFinite(wfmRequiredYogisHiring))
                wfmRequiredYogisHiring = 0;

            $('#txt_112' + datearray[i]).val(wfmRequiredYogisHiring.toFixed(2));//WFM Recommended Yogis Hiring



            if ($('#txt_63' + datearray[i]).val().trim() != '')
                smes = parseFloat($('#txt_63' + datearray[i]).val().trim());
            requiredSMEHeadcount = prodTotal / smes;
            if (isNaN(requiredSMEHeadcount) || !isFinite(requiredSMEHeadcount))
                requiredSMEHeadcount = 0;
            $('#txt_114' + datearray[i]).val(requiredSMEHeadcount.toFixed(2));//Required SME Headcount




            wfmRecommendedSMEHiring = requiredSMEHeadcount - actualSMECount;
            if (isNaN(wfmRecommendedSMEHiring) || !isFinite(wfmRecommendedSMEHiring))
                wfmRecommendedSMEHiring = 0;
            $('#txt_115' + datearray[i]).val(wfmRecommendedSMEHiring.toFixed(2));//WFM Recommended SME Hiring
        });
    },
    OnKeyup: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {
            $('#txt_82' + datearray[i]).bind('propertychange change keyup paste input', function () {

                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });

            $('#txt_7' + datearray[i]).bind('propertychange change keyup paste input', function () {
                $('#txt_16').val($('#txt_7').val().trim());//Support HC
            });
            $('#txt_62' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_92' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });

            $('#txt_93' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_94' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_96' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_98' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_62' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_63' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_64' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_67' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });

            $('#txt_100' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_102' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_104' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_107' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_110' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });
            $('#txt_113' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
            });

            $('#txt_10' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeGoalToTargetAHT();
            });

            $('#txt_11' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeGoalToTargetAHT();
            });

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
    ComputeGoalToTargetAHT: function(){
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
    ComputeProjectedProductionShrinkage: function () {
        var datearray = $('#txtDates').val().trim().split(',');
        $.each(datearray, function (i) {

            var a = 0;
            var b = 0;
            var c = 0;
            var d = 0;

            if ($('#txt_19'+ datearray[i]).val().trim() != '')//Breaks
                a = parseFloat($('#txt_19'+ datearray[i]).val().trim());
            if ($('#txt_20'+ datearray[i]).val().trim() != '')//Coaching + Meeting + Training
                b = parseFloat($('#txt_20'+ datearray[i]).val().trim());
            if ($('#txt_21'+ datearray[i]).val().trim() != '')//System Down Time
                c = parseFloat($('#txt_21'+ datearray[i]).val().trim());
            if ($('#txt_22'+ datearray[i]).val().trim() != '')//Lost Hours
                d = parseFloat($('#txt_22'+ datearray[i]).val().trim());

            var sum = a + b + c + d;
            $('#txt_18'+ datearray[i]).val(sum);//In-center Shrinkage

            var unplanned = 0;
            var planned = 0;
            if ($('#txt_24'+ datearray[i]).val().trim() != '')//Unplanned
                unplanned = parseFloat($('#txt_24'+ datearray[i]).val().trim());
            if ($('#txt_25'+ datearray[i]).val().trim() != '')//Planned
                planned = parseFloat($('#txt_25'+ datearray[i]).val().trim());

            var sumOfPlannedUnplanned = unplanned + planned;

            $('#txt_23'+ datearray[i]).val(sumOfPlannedUnplanned);//Out-of center Shrinkage
            $('#txt_17'+ datearray[i]).val(sum + sumOfPlannedUnplanned);//Overall Projected Production Shrinkage
            ahcManagement.ComputeShrinkageVariance(datearray[i],parseFloat($('#txt_35'+ datearray[i]).val()), parseFloat($('#txt_44'+ datearray[i]).val()), parseFloat($('#txt_17'+ datearray[i]).val()), parseFloat($('#txt_26'+ datearray[i]).val()));
    
        });
    },
    OnKeyupProjectedProductionShrinkage: function () {
        var datearray = $('#txtDates' + datearray[i]).val().trim().split(',');
        $.each(datearray, function (i) {
            //START ProjectedProductionShrinkage
            //Breaks    
            $('#txt_19' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage();
            });
            //Coaching + Meeting + Training
            $('#txt_20' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage();
            });
            //System Down Time
            $('#txt_21' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage();
            });
            //Lost Hours
            $('#txt_22' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage();
            });
            //Unplanned
            $('#txt_24' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage();
            });
            //Planned
            $('#txt_25' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedProductionShrinkage();
            });
            //END ProjectedProductionShrinkage
        });
    },
    ComputeProjectedNestingShrinkage: function () {
        var datearray = $('#txtDates' + datearray[i]).val().trim().split(',');
        $.each(datearray, function (i) {

            var a = 0;
            var b = 0;
            var c = 0;
            var d = 0;

            if ($('#txt_28' + datearray[i]).val().trim() != '')//Breaks
                a = parseFloat($('#txt_28' + datearray[i]).val().trim());
            if ($('#txt_29' + datearray[i]).val().trim() != '')//Coaching + Meeting + Training
                b = parseFloat($('#txt_29' + datearray[i]).val().trim());
            if ($('#txt_30' + datearray[i]).val().trim() != '')//System Down Time
                c = parseFloat($('#txt_30' + datearray[i]).val().trim());
            if ($('#txt_31' + datearray[i]).val().trim() != '')//Lost Hours
                d = parseFloat($('#txt_31' + datearray[i]).val().trim());

            var sum = a + b + c + d;
            $('#txt_27' + datearray[i]).val(sum);//In-center Shrinkage

            var unplanned = 0;
            var planned = 0;
            if ($('#txt_33' + datearray[i]).val().trim() != '')//Unplanned
                unplanned = parseFloat($('#txt_33' + datearray[i]).val().trim());
            if ($('#txt_34' + datearray[i]).val().trim() != '')//Planned
                planned = parseFloat($('#txt_34' + datearray[i]).val().trim());

            var sumOfPlannedUnplanned = unplanned + planned;

            $('#txt_32' + datearray[i]).val(sumOfPlannedUnplanned);//Out-of center Shrinkage
            $('#txt_26' + datearray[i]).val(sum + sumOfPlannedUnplanned);//Overall Projected Production Shrinkage
            ahcManagement.ComputeShrinkageVariance(datearray[i],parseFloat($('#txt_35' + datearray[i]).val()), parseFloat($('#txt_44' + datearray[i]).val()), parseFloat($('#txt_17' + datearray[i]).val()), parseFloat($('#txt_26' + datearray[i]).val()));
        });
    },
    OnKeyupProjectedNestingShrinkage :function(){
        var datearray = $('#txtDates' + datearray[i]).val().trim().split(',');
        $.each(datearray, function (i) {
            //Breaks    
            $('#txt_28' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage();
            });
            //Coaching + Meeting + Training
            $('#txt_29' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage();
            });
            //System Down Time
            $('#txt_30' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage();
            });
            //Lost Hours
            $('#txt_31' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage();
            });
            //Unplanned
            $('#txt_33' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage();
            });
            //Planned
            $('#txt_34' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeProjectedNestingShrinkage();
            });
        });
    },
    ComputeActualProductionShrinkage: function () {
        var datearray = $('#txtDates' + datearray[i]).val().trim().split(',');
        $.each(datearray, function (i) {

            var a = 0;
            var b = 0;
            var c = 0;
            var d = 0;

            if ($('#txt_37' + datearray[i]).val().trim() != '')//Breaks
                a = parseFloat($('#txt_37' + datearray[i]).val().trim());
            if ($('#txt_38' + datearray[i]).val().trim() != '')//Coaching + Meeting + Training
                b = parseFloat($('#txt_38' + datearray[i]).val().trim());
            if ($('#txt_39' + datearray[i]).val().trim() != '')//System Down Time
                c = parseFloat($('#txt_39' + datearray[i]).val().trim());
            if ($('#txt_40' + datearray[i]).val().trim() != '')//Lost Hours
                d = parseFloat($('#txt_40' + datearray[i]).val().trim());

            var sum = a + b + c + d;
            $('#txt_36' + datearray[i]).val(sum);//In-center Shrinkage

            var unplanned = 0;
            var planned = 0;
            if ($('#txt_42' + datearray[i]).val().trim() != '')//Unplanned
                unplanned = parseFloat($('#txt_42' + datearray[i]).val().trim());
            if ($('#txt_43' + datearray[i]).val().trim() != '')//Planned
                planned = parseFloat($('#txt_43' + datearray[i]).val().trim());

            var sumOfPlannedUnplanned = unplanned + planned;

            $('#txt_41' + datearray[i]).val(sumOfPlannedUnplanned);//Out-of center Shrinkage
            $('#txt_35' + datearray[i]).val(sum + sumOfPlannedUnplanned);//Overall Actual Production Shrinkage
            ahcManagement.ComputeShrinkageVariance(datearray[i],parseFloat($('#txt_35' + datearray[i]).val()), parseFloat($('#txt_44' + datearray[i]).val()), parseFloat($('#txt_17' + datearray[i]).val()), parseFloat($('#txt_26' + datearray[i]).val()));
        });
    },
    OnKeyupActualProductionShrinkage: function () {
        var datearray = $('#txtDates' + datearray[i]).val().trim().split(',');
        $.each(datearray, function (i) {
            //Breaks    
            $('#txt_37' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage();
            });
            //Coaching + Meeting + Training
            $('#txt_38' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage();
            });
            //System Down Time
            $('#txt_39' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage();
            });
            //Lost Hours
            $('#txt_40' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage();
            });
            //Unplanned
            $('#txt_42' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage();
            });
            //Planned
            $('#txt_43' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualProductionShrinkage();
            });
        });
    },
    ComputeActualNestingShrinkage: function () {
        var datearray = $('#txtDates' + datearray[i]).val().trim().split(',');
        $.each(datearray, function (i) {

            var a = 0;
            var b = 0;
            var c = 0;
            var d = 0;

            if ($('#txt_46' + datearray[i]).val().trim() != '')//Breaks
                a = parseFloat($('#txt_46' + datearray[i]).val().trim());
            if ($('#txt_47' + datearray[i]).val().trim() != '')//Coaching + Meeting + Training
                b = parseFloat($('#txt_47' + datearray[i]).val().trim());
            if ($('#txt_48' + datearray[i]).val().trim() != '')//System Down Time
                c = parseFloat($('#txt_48' + datearray[i]).val().trim());
            if ($('#txt_49' + datearray[i]).val().trim() != '')//Lost Hours
                d = parseFloat($('#txt_49' + datearray[i]).val().trim());

            var sum = a + b + c + d;
            $('#txt_45' + datearray[i]).val(sum);//In-center Shrinkage

            var unplanned = 0;
            var planned = 0;
            if ($('#txt_51' + datearray[i]).val().trim() != '')//Unplanned
                unplanned = parseFloat($('#txt_51' + datearray[i]).val().trim());
            if ($('#txt_52' + datearray[i]).val().trim() != '')//Planned
                planned = parseFloat($('#txt_52' + datearray[i]).val().trim());

            var sumOfPlannedUnplanned = unplanned + planned;

            $('#txt_50' + datearray[i]).val(sumOfPlannedUnplanned);//Out-of center Shrinkage
            $('#txt_44' + datearray[i]).val(sum + sumOfPlannedUnplanned);//Overall Actual Nesting Shrinkage
            ahcManagement.ComputeShrinkageVariance(datearray[i],parseFloat($('#txt_35' + datearray[i]).val()), parseFloat($('#txt_44' + datearray[i]).val()), parseFloat($('#txt_17' + datearray[i]).val()), parseFloat($('#txt_26' + datearray[i]).val()));
        });
    },
    OnKeyupActualNestingShrinkage: function () {
        var datearray = $('#txtDates' + datearray[i]).val().trim().split(',');
        $.each(datearray, function (i) {
            //Breaks    
            $('#txt_46' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage();
            });
            //Coaching + Meeting + Training
            $('#txt_47' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage();
            });
            //System Down Time
            $('#txt_48' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage();
            });
            //Lost Hours
            $('#txt_49' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage();
            });
            //Unplanned
            $('#txt_51' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage();
            });
            //Planned
            $('#txt_52' + datearray[i]).bind('propertychange change keyup paste input', function () {
                ahcManagement.ComputeActualNestingShrinkage();
            });
        });
    },
    ComputeShrinkageVariance: function (datearrayvalue,txt_35, txt_44, txt_17, txt_26) {
        var variance = ((txt_35 + txt_44) - (txt_17 + txt_26));
        if (isNaN(variance) || !isFinite(variance))
            variance = 0;

        $('#txt_53' + datearrayvalue).val(variance.toFixed(2) + ' %');
    },
    Save: function (url) {
        $('#btnSave').click(function () {
            ahcManagement.SaveData(url);
        });
        $('#btnSave2').click(function () {
            ahcManagement.SaveData(url);
        });
    },
    SaveData: function (url) {
        var txtnames = $('#txtNames').val().split(',');
        var datapointIDs = '';
        var datapointValues ='';
        var campaignID = $('#ddlCampaigns2').val();
        var lobID = $('#ddlLobs2').val();
        var date = $('#datepicker').val();

        txtnames.forEach(function (txtname) {
            //datapointIDs += txtname.replace('#txt_', '') + ',';
            datapointValues += txtname.replace('#txt_', '') + ':' + $(txtname).val() + ',';
        });


        var data = {
            //'datapointIds' : datapointIDs,
            'datapointValues': datapointValues,
            'date': date,
            'campaignID': campaignID,
            'lobID': lobID
        };
        $.post(url, data, function (data) {
            
            $.alert({
                closeIcon: true,
                title: 'WFMPCP | AHC Manager',
                content: data.Message
            });
            ahcManagement.ClearData();
        }, 'json');
    }
}