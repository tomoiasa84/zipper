import 'package:contractor_search/models/WrappedMessage.dart';

class PnGCM {
  WrappedMessage _wrappedMessage;

  PnGCM(this._wrappedMessage);

  WrappedMessage get wrappedMessage => _wrappedMessage;

  Map<String, dynamic> toJson() => {'pn_gcm': _wrappedMessage};

  PnGCM.fromJson(Map<String, dynamic> json)
      : _wrappedMessage = WrappedMessage.fromJson(json['pn_gcm']);
}
