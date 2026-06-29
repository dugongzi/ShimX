/// 供应商上游协议。值需与代理 transformer 内部判断保持一致(改值会破协议层)。
const String providerProtocolResponses = 'responses';
const String providerProtocolChat = 'chat';
const String providerProtocolMessages = 'messages';

const List<String> providerProtocolValues = [
  providerProtocolResponses,
  providerProtocolChat,
  providerProtocolMessages,
];
