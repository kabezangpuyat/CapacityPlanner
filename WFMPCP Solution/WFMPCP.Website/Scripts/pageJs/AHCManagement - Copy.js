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
    Initialize: function () {
        $('#LobID').val('0');
        $('#txtNames').hide();
        $('#IsUpdate').hide();

        //hide widget
        $('#divWidgetBody').hide();
        $('#divWidgetBox').attr('class','widget-box collapsed');
        $('#iIcon').attr('class', 'ace-icon fa fa-chevron-down');

        //PCP input
        $('#txt_1').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_1');
        });
        $('#txt_2').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_2');
        });
        $('#txt_3').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_3');
        });
        $('#txt_4').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_4');
        });
        $('#txt_5').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_5');
        });
        $('#txt_6').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_6');
        });
        $('#txt_7').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_7');
        });
        $('#txt_8').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_8');
        });
        $('#txt_9').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_9');
        });
        $('#txt_10').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_10');
        });
        $('#txt_11').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_11');
        });
        $('#txt_19').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_19');
        });
        $('#txt_20').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_20');
        });
        $('#txt_21').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_21');
        });
        $('#txt_22').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_22');
        });
        $('#txt_24').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_24');
        });
        $('#txt_25').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_25');
        });
        $('#txt_28').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_28');
        });
        $('#txt_29').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_29');
        });
        $('#txt_30').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_30');
        });
        $('#txt_31').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_31');
        });
        $('#txt_33').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_33');
        });
        $('#txt_34').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_34');
        });
        $('#txt_37').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_37');
        });
        $('#txt_38').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_38');
        });
        $('#txt_39').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_39');
        });
        $('#txt_40').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_40');
        });
        $('#txt_42').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_42');
        });
        $('#txt_43').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_43');
        });
        $('#txt_46').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_46');
        });
        $('#txt_47').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_47');
        });
        $('#txt_48').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_48');
        });
        $('#txt_49').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_49');
        });
        $('#txt_51').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_51');
        });
        $('#txt_50').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_50');
        });

        $('#txt_54').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_54');
        });
        $('#txt_55').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_55');
        });
        $('#txt_56').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_56');
        });
        $('#txt_57').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_57');
        });
        $('#txt_58').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_58');
        });
        $('#txt_59').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_59');
        });
        $('#txt_60').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_60');
        });
        $('#txt_61').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_61');
        });
        $('#txt_62').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_62');
        });
        $('#txt_63').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_63');
        });
        $('#txt_64').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_64');
        });
        $('#txt_65').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_65');
        });

        $('#txt_67').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_67');
        });
        $('#txt_73').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_73');
        });
        $('#txt_74').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_74');
        });
        $('#txt_75').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_75');
        });
        $('#txt_76').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_76');
        });
        $('#txt_77').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_77');
        });
        $('#txt_78').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_78');
        });
        $('#txt_82').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_82');
        });
        $('#txt_92').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_92');
        });
        $('#txt_93').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_93');
        });
        $('#txt_94').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_94');
        });
        $('#txt_96').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_96');
        });
        $('#txt_98').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_98');
        });
        $('#txt_100').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_100');
        });
        $('#txt_102').on('keypress keyup blur', function (event) {
            common.AllowFloat(event, '#txt_102');
        });
        $('#txt_104').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_104');
        });
        $('#txt_107').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_107');
        });
        $('#txt_110').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_110');
        });
        $('#txt_113').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_113');
        });
        $('#txt_116').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_116');
        });
        $('#txt_117').on('keypress keyup blur', function (event) {
            common.AllowInt(event, '#txt_117');
        });

       
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
    CampaignChange2: function (campaignChangeURL) {
        $('#ddlCampaigns2').change(function () {
            var campaignID = $('#ddlCampaigns2').val();
            ahcManagement.Initialize();
            
            $('#ddlLobs2')
                .find('option')
                .remove()
                .end()
                .append('<option value="0" selected>[Select LoB]</option>')
                .val('whatever');

            $.post(campaignChangeURL, { "campaignID": campaignID }, function (data) {
                $.each(data, function (index, value) {
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
    TrainingNestingProductionDate:function(){
        $("#txt_88").datepicker({
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: 'mm/dd/yy'
        }).mask("99/99/9999");
        $("#txt_89").datepicker({
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: 'mm/dd/yy'
        }).mask("99/99/9999");
        $("#txt_90").datepicker({
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: 'mm/dd/yy'
        }).mask("99/99/9999");

        $("#txtStart").datepicker({
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: 'yy-mm-dd'
        }).mask("9999-99-99");
        $("#txtEnd").datepicker({
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: 'yy-mm-dd'
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
    ComputeNewCapacityHireScaleupsAndAttritionClassBackfill: function () {

        $('#txt_13').val($('#txt_82').val().trim());//Production HC
        $('#txt_70').val($('#txt_82').val().trim());//Production Total
        $('#txt_80').val($('#txt_82').val().trim());//Production - Site


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

        if ($('#txt_92').val().trim() != '')
            a = parseFloat($('#txt_92').val().trim());

        if ($('#txt_93').val().trim() != '')
            b = parseFloat($('#txt_93').val().trim());

        

        newhireclasses = a + b;
        $('#txt_15').val(newhireclasses);//Training HC
        $('#txt_72').val(newhireclasses);//Training Total
        $('#txt_83').val(newhireclasses);//Week 3- Nesting
        $('#txt_84').val(newhireclasses);//Week 2 - Nesting
        $('#txt_85').val(newhireclasses);//Week 1 - Nesting
        $('#txt_86').val(newhireclasses);//Training - Site
        $('#txt_87').val(newhireclasses);//Wk 1 - Training
        $('#txt_91').val(newhireclasses);//New Hire Classes

        

        week3Nesting = newhireclasses * 3;

        $('#txt_81').val(week3Nesting);//Nesting - Site
        $('#txt_71').val(week3Nesting);//Nesting Total
        $('#txt_14').val(week3Nesting);//Nesting HC

        
        if ($('#txt_80').val().trim() != '')
            txt_80 = parseFloat($('#txt_80').val().trim());

        

        site1 = txt_80 + week3Nesting + newhireclasses
        $('#txt_79').val(site1);

       
        if ($('#txt_70').val().trim() != '')
            prodTotal = parseFloat($('#txt_70').val().trim());
        if ($('#txt_71').val().trim() != '')
            nestingTotal = parseFloat($('#txt_71').val().trim());
        if ($('#txt_72').val().trim() != '')
            trainingTotal = parseFloat($('#txt_72').val().trim());

        totalHC = prodTotal + nestingTotal + trainingTotal;
        if (isNaN(totalHC) || !isFinite(totalHC))
            totalHC = 0;

        $('#txt_66').val(totalHC);//HEADCOUNT>Overview>Total Headcount


        //HEADCOUNT>Overview>Non-Billable HC Computation
        
        if ($('#txt_67').val().trim() != '')
            billableHC = parseFloat($('#txt_67').val().trim());

        nonBillableHC = totalHC - billableHC;
        if (isNaN(nonBillableHC) || !isFinite(nonBillableHC))
            nonBillableHC = 0;

        $('#txt_68').val(nonBillableHC);//HEADCOUNT>Overview>Non-Billable HC
        
        prodNesting = prodTotal + nestingTotal;
        if (isNaN(prodNesting) || !isFinite(prodNesting))
            prodNesting = 0;
        $('#txt_69').val(prodNesting);//HEADCOUNT>Overview>Production + Nesting


        //*****************************************
        //HEADCOUNT>Attrition>Actual Prod Attrition
        //*****************************************
        
        if ($('#txt_76').val().trim() != '') {
            if ($('#txt_80').val().trim() != '')
                prodSite = parseFloat($('#txt_80').val().trim());
            if ($('#txt_96').val().trim() != '')
                actualAttriction = parseFloat($('#txt_96').val().trim());

            actualProdAttrition = actualAttriction / prodSite;
        }

        if (isNaN(actualProdAttrition) || !isFinite(actualProdAttrition))
            actualProdAttrition = 0;
        $('#txt_95').val(actualProdAttrition.toFixed(2) + ' %');
        //*****************************************
        //HEADCOUNT>Attrition>Actual Prod Attrition   END
        //*****************************************

        //*****************************************
        //HEADCOUNT>Attrition>Prod - Actual to Forecasted %
        //*****************************************
        
        if ($('#txt_94').val().trim() != '')
            forcastedProductionAttrition = parseFloat($('#txt_94').val().trim());

     
        prodActualToForcated = actualProdAttrition / forcastedProductionAttrition;
        if (isNaN(prodActualToForcated) || !isFinite(prodActualToForcated))
            prodActualToForcated = 0;

        $('#txt_97').val(prodActualToForcated.toFixed(2) + ' %');
        //*****************************************
        //HEADCOUNT>Attrition>Prod - Actual to Forecasted %  END
        //*****************************************

        //*****************************************
        //HEADCOUNT>Attrition>Prod - Actual Nesting Attrition
        //*****************************************
       
        if ($('#txt_100').val().trim() != '')
            actualAttrition = parseFloat($('#txt_100').val().trim());

        

        actualNestingAttrition = actualAttrition / prodSite;
        if (isNaN(actualNestingAttrition) || !isFinite(actualNestingAttrition))
            actualNestingAttrition = 0;

        $('#txt_99').val(actualNestingAttrition.toFixed(2) + ' %');
        //*****************************************
        //HEADCOUNT>Attrition>Prod - Actual Nesting Attrition   END
        //*****************************************



        //*****************************************
        //HEADCOUNT>Attrition>NEsting - Actual to Forecasted %  
        //*****************************************
        

        if ($('#txt_98').val().trim() != '')
            forecastedNestingAttrition = parseFloat($('#txt_98').val().trim());

        var nestingActualToForecasted = actualNestingAttrition / forecastedNestingAttrition
        if (isNaN(nestingActualToForecasted) || !isFinite(nestingActualToForecasted))
            nestingActualToForecasted = 0;

        $('#txt_101').val(nestingActualToForecasted.toFixed(2) + ' %');
        //*****************************************
        //HEADCOUNT>Attrition>NEsting - Actual to Forecasted %  END
        //*****************************************


        //*****************************************
        //HEADCOUNT>Attrition>Actual Training Attrition  END
        //*****************************************
       

        if (newhireclasses > 0) {
            if ($('#txt_104').val().trim() != '')
                actualAttrition104 = parseFloat($('#txt_104').val().trim());           
        }

        actualTrainingAttrition = actualAttrition104 / newhireclasses;
        if (isNaN(actualTrainingAttrition) || !isFinite(actualTrainingAttrition))
            actualTrainingAttrition = 0;

        $('#txt_103').val(actualTrainingAttrition.toFixed(2) + ' %');

        //*****************************************
        //HEADCOUNT>Attrition>Actual Training Attrition  END
        //*****************************************


        //*****************************************
        //HEADCOUNT>Attrition>Training - Actual to Forecasted %
        //*****************************************
      
        if ($('#txt_102').val().trim() != '')
            forcastedTrainingAttrition = parseFloat($('#txt_102').val().trim());

        trainingActualToForecastedperc = actualTrainingAttrition / forcastedTrainingAttrition;
        if (isNaN(actualTrainingAttrition) || !isFinite(trainingActualToForecastedperc))
            trainingActualToForecastedperc = 0;

        $('#txt_105').val(trainingActualToForecastedperc.toFixed(2) + ' %');
        //*****************************************
        //HEADCOUNT>Attrition>Training - Actual to Forecasted %  END
        //*****************************************

        

        if ($('#txt_107').val().trim() != '')
            actualTLCount = parseFloat($('#txt_107').val().trim());
        if ($('#txt_110').val().trim() != '')
            actualYogiCount = parseFloat($('#txt_110').val().trim());
        if ($('#txt_113').val().trim() != '')
            actualSMECount = parseFloat($('#txt_113').val().trim());

        totalSupportCount = actualTLCount + actualYogiCount + actualSMECount;
        if (isNaN(totalSupportCount) || !isFinite(totalSupportCount))
            totalSupportCount = 0;
        $('#txt_106').val(totalSupportCount.toFixed(2));//TOTAL SUPPORT COUNT

        
        if ($('#txt_62').val().trim() != '')
            teamLeader = parseFloat($('#txt_62').val().trim());

        requiredTLHEadcount = prodTotal / teamLeader
        if (isNaN(requiredTLHEadcount) || !isFinite(requiredTLHEadcount))
            requiredTLHEadcount = 0;
        $('#txt_108').val(requiredTLHEadcount.toFixed(2));//Required TL HEadcount


        wfmRecommendedTLHiring = requiredTLHEadcount - actualTLCount;
        if (isNaN(wfmRecommendedTLHiring) || !isFinite(wfmRecommendedTLHiring))
            wfmRecommendedTLHiring = 0;

        $('#txt_109').val(wfmRecommendedTLHiring.toFixed(2));//WFM Recommended TL Hiring


        //Required Yogis Headcount
    

        if ($('#txt_64').val().trim() != '')
            yogis = parseFloat($('#txt_64').val().trim());

        requiredYogisHeadcount = prodTotal / yogis;
        if (isNaN(requiredYogisHeadcount) || !isFinite(requiredYogisHeadcount))
            requiredYogisHeadcount = 0;

        $('#txt_111').val(requiredYogisHeadcount.toFixed(2));//Required Yogis Headcount


        
        wfmRequiredYogisHiring = requiredYogisHeadcount - actualYogiCount;
        if (isNaN(wfmRequiredYogisHiring) || !isFinite(wfmRequiredYogisHiring))
            wfmRequiredYogisHiring = 0;

        $('#txt_112').val(wfmRequiredYogisHiring.toFixed(2));//WFM Recommended Yogis Hiring

     

        if ($('#txt_63').val().trim() != '')
            smes = parseFloat($('#txt_63').val().trim());
        requiredSMEHeadcount = prodTotal / smes;
        if (isNaN(requiredSMEHeadcount) || !isFinite(requiredSMEHeadcount))
            requiredSMEHeadcount = 0;
        $('#txt_114').val(requiredSMEHeadcount.toFixed(2));//Required SME Headcount


        

        wfmRecommendedSMEHiring = requiredSMEHeadcount - actualSMECount;
        if (isNaN(wfmRecommendedSMEHiring) || !isFinite(wfmRecommendedSMEHiring))
            wfmRecommendedSMEHiring = 0;
        $('#txt_115').val(wfmRecommendedSMEHiring.toFixed(2));//WFM Recommended SME Hiring

    },
    OnKeyup: function () {

        $("#txt_82").bind("propertychange change keyup paste input", function () {

            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });

        $("#txt_7").bind("propertychange change keyup paste input", function () {
            $('#txt_16').val($('#txt_7').val().trim());//Support HC
        });
        $("#txt_62").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_92").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });

        $("#txt_93").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_94").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_96").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_98").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_62").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_63").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_64").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_67").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });

        $("#txt_100").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_102").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_104").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_107").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_110").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });
        $("#txt_113").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeNewCapacityHireScaleupsAndAttritionClassBackfill();
        });

        $("#txt_10").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeGoalToTargetAHT();
        });

        $("#txt_11").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeGoalToTargetAHT();
        });


    },
    OnFocus: function () {
        var array = $('#txtInputtedNames').val().split(',');
        $.each(array, function (i) {
            $(array[i]).bind('focus', function () {
                $(this).val('');
            });
        });       
    },
    ComputeGoalToTargetAHT: function(){
        var projectedAHT = 0;
        var actualAHT = 0;
        if ($("#txt_10").val().trim() != '')
            projectedAHT = parseFloat($("#txt_10").val().trim());
        if ($("#txt_11").val().trim() != '')
            actualAHT = parseFloat($("#txt_11").val().trim());

        var value = projectedAHT / actualAHT;
        //alert( isFinite( value ))

        if (isNaN(value) || !isFinite(value))
            value = 0;

        $("#txt_12").val(value.toFixed(2) + ' %');
    },
    ComputeProjectedProductionShrinkage: function () {
        var a = 0;
        var b = 0;
        var c = 0;
        var d = 0;

        if ($('#txt_19').val().trim() != '')//Breaks
            a = parseFloat($('#txt_19').val().trim());
        if ($('#txt_20').val().trim() != '')//Coaching + Meeting + Training
            b = parseFloat($('#txt_20').val().trim());
        if ($('#txt_21').val().trim() != '')//System Down Time
            c = parseFloat($('#txt_21').val().trim());
        if ($('#txt_22').val().trim() != '')//Lost Hours
            d = parseFloat($('#txt_22').val().trim());

        var sum = a + b + c + d;
        $('#txt_18').val(sum);//In-center Shrinkage

        var unplanned = 0;
        var planned = 0;
        if ($('#txt_24').val().trim() != '')//Unplanned
            unplanned = parseFloat($('#txt_24').val().trim());
        if ($('#txt_25').val().trim() != '')//Planned
            planned = parseFloat($('#txt_25').val().trim());

        var sumOfPlannedUnplanned = unplanned + planned;

        $('#txt_23').val(sumOfPlannedUnplanned);//Out-of center Shrinkage
        $('#txt_17').val(sum + sumOfPlannedUnplanned);//Overall Projected Production Shrinkage
        ahcManagement.ComputeShrinkageVariance(parseFloat($('#txt_35').val()), parseFloat($('#txt_44').val()), parseFloat($('#txt_17').val()), parseFloat($('#txt_26').val()));
    },
    OnKeyupProjectedProductionShrinkage: function () {
        //START ProjectedProductionShrinkage
        //Breaks    
        $("#txt_19").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedProductionShrinkage();
        });
        //Coaching + Meeting + Training
        $("#txt_20").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedProductionShrinkage();
        });
        //System Down Time
        $("#txt_21").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedProductionShrinkage();
        });
        //Lost Hours
        $("#txt_22").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedProductionShrinkage();
        });
        //Unplanned
        $("#txt_24").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedProductionShrinkage();
        });
        //Planned
        $("#txt_25").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedProductionShrinkage();
        });
        //END ProjectedProductionShrinkage
    },
    ComputeProjectedNestingShrinkage: function () {
        var a = 0;
        var b = 0;
        var c = 0;
        var d = 0;

        if ($('#txt_28').val().trim() != '')//Breaks
            a = parseFloat($('#txt_28').val().trim());
        if ($('#txt_29').val().trim() != '')//Coaching + Meeting + Training
            b = parseFloat($('#txt_29').val().trim());
        if ($('#txt_30').val().trim() != '')//System Down Time
            c = parseFloat($('#txt_30').val().trim());
        if ($('#txt_31').val().trim() != '')//Lost Hours
            d = parseFloat($('#txt_31').val().trim());

        var sum = a + b + c + d;
        $('#txt_27').val(sum);//In-center Shrinkage

        var unplanned = 0;
        var planned = 0;
        if ($('#txt_33').val().trim() != '')//Unplanned
            unplanned = parseFloat($('#txt_33').val().trim());
        if ($('#txt_34').val().trim() != '')//Planned
            planned = parseFloat($('#txt_34').val().trim());

        var sumOfPlannedUnplanned = unplanned + planned;

        $('#txt_32').val(sumOfPlannedUnplanned);//Out-of center Shrinkage
        $('#txt_26').val(sum + sumOfPlannedUnplanned);//Overall Projected Production Shrinkage
        ahcManagement.ComputeShrinkageVariance(parseFloat($('#txt_35').val()), parseFloat($('#txt_44').val()), parseFloat($('#txt_17').val()), parseFloat($('#txt_26').val()));
    },
    OnKeyupProjectedNestingShrinkage :function(){
        //Breaks    
        $("#txt_28").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedNestingShrinkage();
        });
        //Coaching + Meeting + Training
        $("#txt_29").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedNestingShrinkage();
        });
        //System Down Time
        $("#txt_30").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedNestingShrinkage();
        });
        //Lost Hours
        $("#txt_31").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedNestingShrinkage();
        });
        //Unplanned
        $("#txt_33").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedNestingShrinkage();
        });
        //Planned
        $("#txt_34").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeProjectedNestingShrinkage();
        });
    },
    ComputeActualProductionShrinkage: function () {
        var a = 0;
        var b = 0;
        var c = 0;
        var d = 0;

        if ($('#txt_37').val().trim() != '')//Breaks
            a = parseFloat($('#txt_37').val().trim());
        if ($('#txt_38').val().trim() != '')//Coaching + Meeting + Training
            b = parseFloat($('#txt_38').val().trim());
        if ($('#txt_39').val().trim() != '')//System Down Time
            c = parseFloat($('#txt_39').val().trim());
        if ($('#txt_40').val().trim() != '')//Lost Hours
            d = parseFloat($('#txt_40').val().trim());

        var sum = a + b + c + d;
        $('#txt_36').val(sum);//In-center Shrinkage

        var unplanned = 0;
        var planned = 0;
        if ($('#txt_42').val().trim() != '')//Unplanned
            unplanned = parseFloat($('#txt_42').val().trim());
        if ($('#txt_43').val().trim() != '')//Planned
            planned = parseFloat($('#txt_43').val().trim());

        var sumOfPlannedUnplanned = unplanned + planned;

        $('#txt_41').val(sumOfPlannedUnplanned);//Out-of center Shrinkage
        $('#txt_35').val(sum + sumOfPlannedUnplanned);//Overall Actual Production Shrinkage
        ahcManagement.ComputeShrinkageVariance(parseFloat($('#txt_35').val()), parseFloat($('#txt_44').val()), parseFloat($('#txt_17').val()), parseFloat($('#txt_26').val()));
    },
    OnKeyupActualProductionShrinkage: function () {
        //Breaks    
        $("#txt_37").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualProductionShrinkage();
        });
        //Coaching + Meeting + Training
        $("#txt_38").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualProductionShrinkage();
        });
        //System Down Time
        $("#txt_39").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualProductionShrinkage();
        });
        //Lost Hours
        $("#txt_40").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualProductionShrinkage();
        });
        //Unplanned
        $("#txt_42").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualProductionShrinkage();
        });
        //Planned
        $("#txt_43").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualProductionShrinkage();
        });
    },
    ComputeActualNestingShrinkage: function () {
        var a = 0;
        var b = 0;
        var c = 0;
        var d = 0;

        if ($('#txt_46').val().trim() != '')//Breaks
            a = parseFloat($('#txt_46').val().trim());
        if ($('#txt_47').val().trim() != '')//Coaching + Meeting + Training
            b = parseFloat($('#txt_47').val().trim());
        if ($('#txt_48').val().trim() != '')//System Down Time
            c = parseFloat($('#txt_48').val().trim());
        if ($('#txt_49').val().trim() != '')//Lost Hours
            d = parseFloat($('#txt_49').val().trim());

        var sum = a + b + c + d;
        $('#txt_45').val(sum);//In-center Shrinkage

        var unplanned = 0;
        var planned = 0;
        if ($('#txt_51').val().trim() != '')//Unplanned
            unplanned = parseFloat($('#txt_51').val().trim());
        if ($('#txt_52').val().trim() != '')//Planned
            planned = parseFloat($('#txt_52').val().trim());

        var sumOfPlannedUnplanned = unplanned + planned;

        $('#txt_50').val(sumOfPlannedUnplanned);//Out-of center Shrinkage
        $('#txt_44').val(sum + sumOfPlannedUnplanned);//Overall Actual Nesting Shrinkage
        ahcManagement.ComputeShrinkageVariance(parseFloat($('#txt_35').val()), parseFloat($('#txt_44').val()), parseFloat($('#txt_17').val()), parseFloat($('#txt_26').val()));
    },
    OnKeyupActualNestingShrinkage: function () {
        //Breaks    
        $("#txt_46").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualNestingShrinkage();
        });
        //Coaching + Meeting + Training
        $("#txt_47").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualNestingShrinkage();
        });
        //System Down Time
        $("#txt_48").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualNestingShrinkage();
        });
        //Lost Hours
        $("#txt_49").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualNestingShrinkage();
        });
        //Unplanned
        $("#txt_51").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualNestingShrinkage();
        });
        //Planned
        $("#txt_52").bind("propertychange change keyup paste input", function () {
            ahcManagement.ComputeActualNestingShrinkage();
        });
    },
    ComputeShrinkageVariance: function (txt_35, txt_44, txt_17, txt_26) {
        var variance = ((txt_35 + txt_44) - (txt_17 + txt_26));
        if (isNaN(variance) || !isFinite(variance))
            variance = 0;

        $("#txt_53").val(variance.toFixed(2) + ' %');
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
            //"datapointIds" : datapointIDs,
            "datapointValues": datapointValues,
            "date": date,
            "campaignID": campaignID,
            "lobID": lobID
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