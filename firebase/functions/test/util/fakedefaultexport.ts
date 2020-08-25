import * as sinon from "sinon";
import * as tssinon from "ts-sinon";

export function fakeDefaultExport(
  moduleRelativePath: string,
  stubs: Map<string, sinon.SinonStub>
) {
  if (require.cache[require.resolve(moduleRelativePath)]) {
    delete require.cache[require.resolve(moduleRelativePath)];
  }
  for (let [key, value] of stubs) {
    const mod = tssinon.stubInterface<NodeModule>();
    mod.exports.returns(value);
    require.cache[require.resolve(key)] = mod;
  }

  return require(moduleRelativePath);
}
