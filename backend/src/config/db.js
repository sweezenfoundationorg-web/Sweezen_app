const { MongoClient } = require('mongodb');
require('dotenv').config();

const mongoUrl = process.env.MONGO_URL || "mongodb+srv://sweezenfoundationorg_db_user:tCUE2EtQZOp4FK7G@sweezen.hlvaf4g.mongodb.net/?appName=sweezen";
const dbName = process.env.DB_NAME || "sweezen";

let client = null;
let dbInstance = null;

// Connect to MongoDB Database
const connectDb = async () => {
  if (dbInstance) return dbInstance;
  try {
    client = new MongoClient(mongoUrl);
    await client.connect();
    dbInstance = client.db(dbName);
    console.log(`[MongoDB] Successfully connected to database: "${dbName}"`);
    return dbInstance;
  } catch (err) {
    console.error(`[MongoDB Connection Error]`, err.message);
    console.warn(`[Fallback] Operating with memory store layer.`);
    return null;
  }
};

const getDb = () => dbInstance;

const getCollection = (colName) => {
  if (!dbInstance) return null;
  return dbInstance.collection(colName);
};

// Memory Database Store fallback for zero-downtime execution
class MemoryStore {
  constructor() {
    this.users = [];
    this.otps = [];
    this.projects = [];
    this.donations = [];
    this.tasks = [];
    this.events = [];
    this.registrations = [];
    this.humanityCards = [];
    this.humanityLogs = [];
    this.announcements = [];
    this.groupMessages = [];
    this.reports = [];
  }
}

const memoryDb = new MemoryStore();

module.exports = {
  connectDb,
  getDb,
  getCollection,
  memoryDb
};
