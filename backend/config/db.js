import mongoose from 'mongoose'

const connectDB = async () => {
  // Determine MongoDB connection string. Prefer MONGO_URI, but allow
  // building one from individual parts if provided (useful in Docker setups).
  const { MONGO_URI, MONGO_ROOT_USER, MONGO_ROOT_PASSWORD, MONGO_HOST, MONGO_DB } = process.env

  let mongoUri = MONGO_URI

  if (!mongoUri && MONGO_ROOT_USER && MONGO_ROOT_PASSWORD && MONGO_HOST) {
    // Build a basic URI: mongodb://user:pass@host:27017/db?authSource=admin
    const dbName = MONGO_DB || 'proshop'
    mongoUri = `mongodb://${encodeURIComponent(MONGO_ROOT_USER)}:${encodeURIComponent(
      MONGO_ROOT_PASSWORD
    )}@${MONGO_HOST}:27017/${dbName}?authSource=admin`
  }

  if (!mongoUri) {
    console.error(
      'Error: MongoDB connection string is not set. Please set the MONGO_URI environment variable, or provide MONGO_ROOT_USER, MONGO_ROOT_PASSWORD and MONGO_HOST.'
    )
    process.exit(1)
  }

  try {
    const conn = await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    })

    console.log(`MongoDB Connected: ${conn.connection.host}`.cyan.underline)
  } catch (error) {
    console.error(`Error connecting to MongoDB: ${error.message}`.red.underline.bold)
    process.exit(1)
  }
}

export default connectDB
