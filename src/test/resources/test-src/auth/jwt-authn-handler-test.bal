import ballerina/auth;
import ballerina/http;
import ballerina/crypto;

function testCanHandleHttpJwtAuthWithoutHeader() returns (boolean) {
    http:HttpJwtAuthnHandler handler = new(createJwtAuthProvider("ballerina/security/ballerinaTruststore.p12"));
    http:Request request = createRequest();
    string authHeaderValue = "Basic xxxxxx";
    request.setHeader("Authorization", authHeaderValue);
    return handler.canHandle(request);
}

function testCanHandleHttpJwtAuth() returns (boolean) {
    http:HttpJwtAuthnHandler handler = new(createJwtAuthProvider("ballerina/security/ballerinaTruststore.p12"));
    http:Request request = createRequest();
    string authHeaderValue = "Bearer xxx.yyy.zzz";
    request.setHeader("Authorization", authHeaderValue);
    return handler.canHandle(request);
}

function testHandleHttpJwtAuthFailure() returns (boolean) {
    http:HttpJwtAuthnHandler handler = new(createJwtAuthProvider("ballerina/security/ballerinaTruststore.p12"));
    http:Request request = createRequest();
    string authHeaderValue = "Bearer xxx.yyy.zzz";
    request.setHeader("Authorization", authHeaderValue);
    return handler.handle(request);
}

function testHandleHttpJwtAuth(string token, string trustStorePath) returns (boolean) {
    http:HttpJwtAuthnHandler handler = new(createJwtAuthProvider(trustStorePath));
    http:Request request = createRequest();
    string authHeaderValue = "Bearer " + token;
    request.setHeader("Authorization", authHeaderValue);
    return handler.handle(request);
}

function createRequest() returns (http:Request) {
    http:Request inRequest = new;
    inRequest.rawPath = "/helloWorld/sayHello";
    inRequest.method = "GET";
    inRequest.httpVersion = "1.1";
    return inRequest;
}

function createJwtAuthProvider(string trustStorePath) returns auth:JWTAuthProvider {
    crypto:TrustStore trustStore = {
        path: trustStorePath,
        password: "ballerina"
    };
    auth:JWTAuthProviderConfig jwtConfig = {
        issuer: "wso2",
        audience: "ballerina",
        certificateAlias: "ballerina",
        trustStore: trustStore
    };
    auth:JWTAuthProvider jwtAuthProvider = new(jwtConfig);
    return jwtAuthProvider;
}

function generateJwt(auth:JwtHeader header, auth:JwtPayload payload, string keyStorePath) returns string|error {
    crypto:KeyStore keyStore = { path: keyStorePath, password: "ballerina" };
    return auth:issueJwt(header, payload, keyStore, "ballerina", "ballerina");
}

function verifyJwt(string jwt, auth:JWTValidatorConfig config) returns auth:JwtPayload|error {
    return auth:validateJwt(jwt, config);
}
