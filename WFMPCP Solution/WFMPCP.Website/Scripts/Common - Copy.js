var common = {
    GetUrlParameter: function (sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
    },
    Convert: function (d) {
        // Converts the date in d to a date-object. The input can be:
        //   a date object: returned without modification
        //  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
        //   a number     : Interpreted as number of milliseconds
        //                  since 1 Jan 1970 (a timestamp) 
        //   a string     : Any format supported by the javascript engine, like
        //                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
        //  an object     : Interpreted as an object with year, month and date
        //                  attributes.  **NOTE** month is 0-11.
        return (
            d.constructor === Date ? d :
            d.constructor === Array ? new Date(d[0], d[1], d[2]) :
            d.constructor === Number ? new Date(d) :
            d.constructor === String ? new Date(d) :
            typeof d === "object" ? new Date(d.year, d.month, d.date) :
            NaN
        );
    },
    Compare: function (a, b) {
        // Compare two dates (could be of any type supported by the convert
        // function above) and returns:
        //  -1 : if a < b
        //   0 : if a = b
        //   1 : if a > b
        // NaN : if a or b is an illegal date
        // NOTE: The code inside isFinite does an assignment (=).
        var d1 = new Date(a);
        var d2 = new Date(b);

        if (d1 < d2)
            return -1;
        if (d1 == d2)
            return 0;
        if (d1 > d2)
            return 1;
        else
            return 0;

        //return (
        //    isFinite(a = this.convert(a).valueOf()) &&
        //    isFinite(b = this.convert(b).valueOf()) ?
        //    (a > b) - (a < b) :
        //    NaN
        //);
    },
    InRange: function (d, start, end) {
        // Checks if date in d is between dates in start and end.
        // Returns a boolean or NaN:
        //    true  : if d is between start and end (inclusive)
        //    false : if d is before start or after end
        //    NaN   : if one or more of the dates is illegal.
        // NOTE: The code inside isFinite does an assignment (=).
        return (
             isFinite(d = this.convert(d).valueOf()) &&
             isFinite(start = this.convert(start).valueOf()) &&
             isFinite(end = this.convert(end).valueOf()) ?
             start <= d && d <= end :
             NaN
         );
    },
    GetDateNow: function () {
        var d = new Date();

        //var completeDate = (d.getMonth() + 1) + "/" + d.getDate() + "/" + d.getFullYear();
        //if( completeDate.length ==

        var dateString = (d.getMonth() + 1) + "/" + d.getDate() + "/" + d.getFullYear();
        return dateString;
    },
    ClearTextBox: function (txtboxName) {
        document.getElementById(txtboxName).value = '';
    },
    IsNumber: function (a) {
        if (a.match(/[a-zA-Z]/g))
            return false;
        else
            return true;
    },
    SelectIndexToZero: function (selectName) {
        document.getElementById(selectName).value = '0';
    },
    IsNumberKey: function (evt) {
        var theEvent = evt || window.event;
        var key = theEvent.keyCode || theEvent.which;
        key = String.fromCharCode(key);
        var regex = /[0-9]|\./;
        if (!regex.test(key)) {
            theEvent.returnValue = false;
            if (theEvent.preventDefault) theEvent.preventDefault();
        }
    },
    OnKeyUpNotZero: function (value, txtname) {
        if (value == '0')
            document.getElementById(txtname).value = '1';
    },
    ShowCustomAlert: function (url, header, message, display) {
        $.post(url, { "header": header, "message": message, "display": display }, function (data) {
            $('#divCustomPopupContainer').empty().html(data);
        });
    },
    ShowCustomConfirm: function (url, header, message, display, jsfunction) {
        $.post(url, { "header": header, "message": message, "display": display, "onConfirm": jsfunction }, function (data) {
            $('#divCustomPopupContainer').empty().html(data);
        });
    },
    IsValidEmail: function (email) {
        var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(email);
    },
    ClientDate: function () {
        var dateObj = new Date();
        var month = dateObj.getUTCMonth() + 1;
        var day = dateObj.getUTCDate();
        var year = dateObj.getUTCFullYear();
        var dateToday = month + "/" + day + "/" + year;

        return dateToday;
    },
    IsNumberKey: function (evt) {
        var theEvent = evt || window.event;
        var key = theEvent.keyCode || theEvent.which;
        key = String.fromCharCode(key);
        var regex = /[0-9]|\./;
        if (!regex.test(key)) {
            theEvent.returnValue = false;
            if (theEvent.preventDefault) theEvent.preventDefault();
        }
    },
    NumberOfWords: function (v) {
        var matches = v.match(/\S+/g);
        return matches ? matches.length : 0;
    },
    //JQGRID
    UpdateJQGridPagerIcons: function(table){
        var replacement =
                {
                    'ui-icon-seek-first': 'ace-icon fa fa-angle-double-left bigger-140',
                    'ui-icon-seek-prev': 'ace-icon fa fa-angle-left bigger-140',
                    'ui-icon-seek-next': 'ace-icon fa fa-angle-right bigger-140',
                    'ui-icon-seek-end': 'ace-icon fa fa-angle-double-right bigger-140'
                };
        $('.ui-pg-table:not(.navtable) > tbody > tr > .ui-pg-button > .ui-icon').each(function () {
            var icon = $(this);
            var $class = $.trim(icon.attr('class').replace('ui-icon', ''));

            if ($class in replacement) icon.attr('class', 'ui-icon ' + replacement[$class]);
        });
    },
    EnableJQGridTootTips: function (table) {
        $('.navtable .ui-pg-button').tooltip({ container: 'body' });
        $(table).find('.ui-pg-div').tooltip({ container: 'body' });
    },
    GetMonday: function () {
        var d = new Date();
        var day = d.getDay(),
            diff = d.getDate() - day + (day == 0 ? -6 : 1); // adjust when day is sunday
        return new Date(d.setDate(diff));
    },
    AddDays: function (theDate, days) {
        return new Date(theDate.getTime() + days * 24 * 60 * 60 * 1000);
    },
    AllowFloat: function(event,txt){
        $(txt).val($(txt).val().replace(/[^0-9\.]/g, ''));
        if ((event.which != 46 || $(txt).val().indexOf('.') != -1) && (event.which < 48 || event.which > 57)) {
            event.preventDefault();
        }
    },
    AllowInt: function(event,txt){
        $(txt).val($(txt).val().replace(/[^\d].+/, ""));
        if ((event.which < 48 || event.which > 57)) {
            event.preventDefault();
        }
    },
}