import set from 'lodash.set';
import camelCase from 'camelcase';
import glob from 'glob';
import admin from 'firebase-admin';
import { resolve } from 'path';

admin.initializeApp();

const files = glob.sync("./**/*.f.js", {
  cwd: __dirname,
  ignore: "./node_modules/**"
});

const funcNameFromRelPath = (relPath: string): string => {
  return camelCase(relPath.slice(0, -5).split('/').join('_'));
};

const funcDir = './';
for (let f = 0, fl = files.length; f < fl; f++) {
  const file = files[f];
  const absPath = resolve(__dirname, funcDir, file);
  // Avoid exporting the index file.
  if (absPath.slice(0, -2) === __filename.slice(0, -2)) continue;
  // Make a nice function name.
  const functionName = funcNameFromRelPath(
    file
  );
  const propPath = functionName.replace(/-/g, '.');
  console.log('Starting ' + process.env.FUNCTION_NAME);
  console.log('Starting ' + functionName);
  if (
    !process.env.FUNCTION_NAME ||
    process.env.FUNCTION_NAME === functionName
  ) {
     const module = require(resolve(__dirname, funcDir, file));
     if (!module.default) continue;
     set(exports, propPath, module.default);
  }
}
