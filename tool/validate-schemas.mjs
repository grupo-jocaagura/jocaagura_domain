import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import Ajv2020 from 'ajv/dist/2020.js';
import addFormats from 'ajv-formats';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, '..');
const schemaDir = path.join(repoRoot, 'doc', 'schemas', 'v1');
const examplesDir = path.join(schemaDir, 'examples');

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function getSchemaBaseName(schemaFileName) {
  return schemaFileName.replace(/\.schema\.json$/i, '');
}

const ajv = new Ajv2020({
  strict: false,
  allErrors: true,
  validateFormats: true,
});
addFormats(ajv);

const schemaFiles = fs
  .readdirSync(schemaDir, { withFileTypes: true })
  .filter((entry) => entry.isFile() && entry.name.endsWith('.schema.json'))
  .map((entry) => entry.name)
  .sort();

for (const schemaFile of schemaFiles) {
  const schemaPath = path.join(schemaDir, schemaFile);
  const schema = readJson(schemaPath);
  ajv.addSchema(schema, schema.$id ?? schemaPath);
}

for (const schemaFile of schemaFiles) {
  const schemaPath = path.join(schemaDir, schemaFile);
  const schema = readJson(schemaPath);
  const validate =
    (schema.$id && ajv.getSchema(schema.$id)) ||
    ajv.getSchema(schemaPath) ||
    ajv.compile(schema);

  const examplePath = path.join(
    examplesDir,
    `${getSchemaBaseName(schemaFile)}.example.json`,
  );

  if (!fs.existsSync(examplePath)) {
    throw new Error(`Example file not found for schema ${schemaFile}: ${examplePath}`);
  }

  const example = readJson(examplePath);
  const valid = validate(example);
  if (!valid) {
    throw new Error(
      `Example validation failed for ${examplePath}: ${ajv.errorsText(validate.errors, {
        separator: '\n',
      })}`,
    );
  }
}

console.log('AJV validation completed successfully.');
