const fs = require('fs-extra');
const path = require('path');

// Define a basic template for Cargo.toml
const generateCargoToml = (folderName) => `
[package]
name = "${folderName}"
version = "0.1.0"
edition = "2021"

[dependencies]
`;

// Get all directories in the current directory
const currentDir = process.cwd();
fs.readdir(currentDir, (err, files) => {
  if (err) throw err;

  files.forEach(file => {
    const filePath = path.join(currentDir, file);
    // Check if the file is a directory
    if (fs.statSync(filePath).isDirectory()) {
      const cargoTomlPath = path.join(filePath, 'Cargo.toml');

      // If Cargo.toml does not exist, create it
      if (!fs.existsSync(cargoTomlPath)) {
        const content = generateCargoToml(file);
        fs.writeFileSync(cargoTomlPath, content);
        console.log(`Created Cargo.toml in ${file}`);
      } else {
        console.log(`Cargo.toml already exists in ${file}, skipping...`);
      }
    }
  });
});
