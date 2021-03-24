var userManagement = {
    OnUserLevelChange: function (url) {     

        $('#ddlUserLevels').change(function () {
            var userLevel = this.value;
            $('#ddlUsers')
                .find('option')
                .remove()
                .end()
                .append('<option value="0" selected>Select User</option>')
                .val('whatever');
            userManagement.OnLoadUsers(url,userLevel);
            //$.post(url, { "userLevel": userLevel }, function (data) {              

            //    $.each(data.UsersVM, function (index, value) {
            //        //if (common.IsNumber(value.EmployeeID)) {
            //            $('#ddlUsers').append($('<option>', { value: value.EmployeeID, text: value.FullName }));
            //        //}
            //    });
            //}, 'json');
        });
    },
    OnSaveClick : function(url,gridTable,urlClearUsers)
    {
        $('#btnDelete').click(function () {
            $.confirm({
                closeIcon: true,
                title: 'WFMPCP | User Manager',
                content: 'Delete data?',
                confirmButton: 'Yes',
                cancelButton: 'No',
                confirm: function () {
                    //call action
                    var userId = $('#txtUserId').val();
                    var isAdd = false;
                    var status = false;
                    if (userId != "0")
                        isAdd = false;

                    var data = {
                        ID: userId,
                        EmployeeID: $('#ddlUsers').val(),
                        RoleID: $('#ddlRoles').val(),
                        IsDeactivate: true,
                        IsAdd: isAdd,
                        Status: status
                    }

                    $.post(url, data, function (data) {
                        //clear dta
                        userManagement.OnClear(urlClearUsers);
                        //refresh jqgrid
                        $(gridTable).trigger("reloadGrid");

                        if ($.trim(data.Message) != "") {
                            var msg = data.Message;
                            if (data.Message == 'Data updated.')
                                msg = 'Data deleted.';

                            $.alert({
                                closeIcon: true,
                                title: 'WFMPCP | User Manager',
                                content: msg
                            });
                        }
                    }, 'json');

                }
            });
        });

        $('#btnSave').click(function ()
        {
            var msg = "";

            if ($('#ddlUsers').val() == "0")
                msg += "User is requried. <br />";

            //if ($('#ddlStatus').val() == "-1")
            //    msg += "Status is requried. <br />";


            if ($.trim(msg) == '') {
                //save data
                $.confirm({
                    closeIcon: true,
                    title: 'WFMPCP | User Manager',
                    content: 'Save data?',
                    confirmButton: 'Yes',
                    cancelButton: 'No',
                    confirm: function () {
                        //call action
                        var userId = $('#txtUserId').val();
                        var isAdd = true;
                        var status = true;
                        if( userId != "0")
                            isAdd = false;

                        //if($('#ddlStatus').val()=="0")
                            status = true;

                        var data = {                            
                            EmployeeID: $('#ddlUsers').val(),
                            RoleID: $('#ddlRoles').val(),
                            IsAdd: isAdd,
                            Status: status,
                            IsDeactivate: false
                        }
                    
                        $.post(url, data, function (data) {
                            //clear dta
                            userManagement.OnClear(urlClearUsers);
                            //refresh jqgrid
                            $(gridTable).trigger("reloadGrid");

                            if ($.trim(data.Message) != "") {
                                $.alert({
                                    closeIcon: true,
                                    title: 'WFMPCP | User Manager',
                                    content: data.Message
                                });
                            }                           
                        },'json');
                        
                    }
                });
            }
            else {
                $.alert({
                    closeIcon: true,
                    title: 'WFMPCP | User Manager',
                    content: msg
                });
            }
        });
  
    },
    OnClear: function (url) {
        $('#txtUserId').val('0');
        $('#ddlRoles').val('0');
        $('#ddlStatus').val('-1');
        $('#ddlUserLevels').val('0');
        $('#btnDelete').hide();
        userManagement.OnLoadUsers(url, "0");       
    },
    OnCancel: function(url){
        $('#btnCancel').click(function () {
            userManagement.OnClear(url);
        });
    },
    OnLoadUsers: function(url,val)
    {
        $('#ddlUsers')
               .find('option')
               .remove()
               .end()
               .append('<option value="0" selected>Select User</option>')
               .val('whatever');
       
        $.post(url, { "userLevel": val }, function (data) {
            $.each(data.UsersVM, function (index, value) {
                if (value.FullName != 'Senior Operations Manager')
                    $('#ddlUsers').append($('<option>', { value: value.EmployeeID, text: value.FullName }));
                //}
            });
        }, 'json');
    },
    OnGridSelectRow: function (id,url) {
        $('#txtUserId').val(id);
        $('#btnDelete').show();
        $.post(url, { id: id }, function (data) {
            //show data in textbox
            $('#ddlUsers').val(data.EmployeeID);
            $('#ddlStatus').val(data.Active);
            $('#ddlRoles').val(data.RoleID);
        }, 'json');
    }
}