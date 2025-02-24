# Use official Node.js image
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy all files from the project directory to the container
COPY . .

# Expose the port (same as your Node.js app)
EXPOSE 3000

# Correct CMD format (JSON array)
CMD ["node", "server.js"]
