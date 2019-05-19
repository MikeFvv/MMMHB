//
//
//require("NetRequestManager, UIAlertView, FunctionManager, NSPredicate");
//
//defineClass("AgentCenterViewController", {
//            toBeAgent: function() {
//            NetRequestManager.sharedInstance().askForToBeAgentWithSuccess_fail(block("void, id", function(object) {
//                                                                                     var alert = UIAlertView.alloc().initWithTitle_message_delegate_cancelButtonTitle_otherButtonTitles("温馨提示", object.objectForKey("data"), null, "好的", null, null);
//                                                                                     alert.show();
//                                                                                     self.requestUserinfo();
//                                                                                     }), block("void, id", function(object) {
//                                                                                               FunctionManager.sharedInstance().handleFailResponse(object);
//                                                                                               }));
//            }
//            }, {});
//
//
//defineClass("AddMemberController", {
//            textFieldDidChangeValue: function(text) {
//            var textField = text.object();
//            if (textField.text().length() == 0) {
//            return;
//            }
//            var num = "^[0-9]*$";
//            var pre = NSPredicate.predicateWithFormat("SELF MATCHES %@", num);
//            var isNum = pre.evaluateWithObject(textField.text());
//            if (isNum) {
//            self.getUserInfoData();
//            }
//            }
//            }, {});
