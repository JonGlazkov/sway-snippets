import { Provider, Wallet } from "fuels";
import { ValidityContractAbi__factory } from "./types";
import { validityContract } from "./types/contract-ids.json";

function convertBytesToNameList(bytes: number[]) {
  const result: string[] = [];

  const [, size] = bytes.splice(0, 2);
  const name = String.fromCharCode(...bytes.splice(0, size));
  result.push(name);

  if (bytes.length) {
    result.push(...convertBytesToNameList(bytes));
  }

  return result;
}

const getContract = async () => {
  const provider = await Provider.create("http://localhost:4000/graphql");
  const wallet = Wallet.fromPrivateKey(
    "0xa449b1ffee0e2205fa924c6740cc48b3b473aa28587df6dab12abc245d1f5298",
    provider
  );
  const contractAbi = ValidityContractAbi__factory.connect(
    validityContract,
    wallet
  );

  return { contractAbi, wallet, provider };
};

async function main() {
  const { contractAbi, wallet } = await getContract();

  const txParams = {
    gasPrice: 1,
    gasLimit: 2_000_000,
  };

  const listResult = await contractAbi.functions
    .test_read_bytes()
    .txParams(txParams)
    .call();

  // const timestamp = TAI64.fromString(
  //   listResult.value[3].toString(),
  //   10
  // ).toUnix();

  console.log(listResult.value);
  // console.log(new Date(timestamp * 1000));
}

// 1000000
// 8992413

main();
