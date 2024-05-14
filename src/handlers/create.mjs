'use strict'

import { PutCommand } from "@aws-sdk/lib-dynamodb";
import { ddbDocClient } from "./libs/ddbDocClient.mjs";
import { randomUUID } from "crypto";

const tableName = process.env.DYNAMODB_TABLE_NAME  

export const handler = async (event) => {
    console.log("Event===", JSON.stringify(event, null, 2))

    return {
        statusCode: 200,
        body: JSON.stringify({ message: "Hello World!" }),
    };
}
