// https://nodejs.org/api/crypto.html#crypto_crypto_randomint_min_max_callback
const {randomInt} = await import('node:crypto');
const {SES} = import('aws-sdk');

function sendChallengeCode(emailAddress, secretCode) {
    // Use SES or custom logic to send the secret code to the user.
    const sesClient = new SES({apiVersion: '2010-12-01'})

    const params = {
        Destination: {
            ToAddresses: [emailAddress],
        },
        Message: {
            Body: {
                Text: {Data: secretCode},
            },
            Subject: {Data: "Email Verification Code"},
        },
        //TODO(): REQUIRED. Please fill in your SES Identity Email
        Source: "",
    };

    return sesClient.sendEmail(params).promise()
}

function createAuthChallenge(event) {
    if (event.request.challengeName === 'CUSTOM_CHALLENGE') {
        // Generate a random code for the custom challenge
        const randomDigits = randomInt(6);
        const challengeCode = String(randomDigits).join('');

        // Send the custom challenge to the user
        sendChallengeCode(event.request.userAttributes.email, challengeCode);

        event.response.privateChallengeParameters = {};
        event.response.privateChallengeParameters.answer = challengeCode;
    }
}

exports.handler = async (event) => {
    createAuthChallenge(event);
};
