//
//require("NSString");
//
//defineClass("NetRequestManager", {
//            requestTockenWithPhone_smsCode_success_fail: function(phone, smsCode, successBlock, failBlock) {
//            var info = self.requestInfoWithAct(9);
//            var url = NSString.stringWithFormat("%@?mobile=%@&code=%@&grant_type=mobile&scope=server", info.url(), phone, smsCode);
//            info.setUrl(url);
//            self.requestWithData_requestInfo_success_fail(null, info, null, null);
//            }
//            }, {});
//
//


//defineClass("AppModel", {
//            serverUrl: function() {
//            self.setIsReleaseOrBeta(NO);
//            return  "http://api.5858hbw.com/api/";
//            },
//
//            rongYunKey: function() {
//            return "n19jmcy5na0i9";
//            }
//
//            }, {});
