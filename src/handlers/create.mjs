'use strict'

import { PutCommand } from "@aws-sdk/lib-dynamodb";
import { ddbDocClient } from "./libs/ddbDocClient.mjs";
import { randomUUID } from "crypto";

const tableName = process.env.DYNAMODB_TABLE_NAME  

export const handler = async (event) => {
    console.log("Event===", JSON.stringify(event, null, 2))

    const getStatusCode = () => {
        const statusCodes = {
            200: {statusCode: 200,
                body: JSON.stringify({ message: "Hello World!" })},
            400: {statusCode: 400,
                body: JSON.stringify({ message: "Bad Request!" })},
            403: {statusCode: 403,
                body: JSON.stringify({ message: "Forbidden!" })},
            404: {statusCode: 404,
                body: JSON.stringify({ message: "File Not Found!" })},
            500: {statusCode: 500,
                body: JSON.stringify({ message: "Internal Server Error!" })},
            504: {statusCode: 504,
                body: JSON.stringify({ message: "Gateway Timeout!" })}
        }

    const keys = Object.keys(statusCodes)
    const randomKey = keys[Math.floor(Math.random() * keys.length)]
    return statusCodes[randomKey]
}
const randomStatusCode = getStatusCode()
    return randomStatusCode;
}
