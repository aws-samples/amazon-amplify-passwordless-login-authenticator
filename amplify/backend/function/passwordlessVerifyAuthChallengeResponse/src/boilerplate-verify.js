function verifyAuthChallengeResponse(event) {
  event.response.answerCorrect = event.request.privateChallengeParameters.answer === event.request.challengeAnswer;
}

/**
 * @type {import('@types/aws-lambda').VerifyAuthChallengeResponseTriggerHandler}
 */
exports.handler = async event => {
  verifyAuthChallengeResponse(event);
};
