import { Provider, Wallet } from "fuels";
import { TAI64 } from "tai64";
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

  try {
    // const listResult = await contractAbi.functions
    //   .test_verify_grace_period()
    //   .txParams(txParams)
    //   .call();
    const domain = await contractAbi.functions
      .register_domain("mydomain")
      .txParams(txParams)
      .call();

    // const timestamp = TAI64.fromString(
    //   listResult.logs[1].toString(),
    //   10
    // ).toUnix();

    // console.log(timestamp);
    // console.log(new Date(timestamp * 1000));
    // const [currentTimestamp, calculatedTimestamp] = domain.logs;
    // console.log({
    //   currentTimestamp: TAI64.fromString(
    //     currentTimestamp.toString(),
    //     10
    //   ).toUnix(),
    //   calculatedTimestamp: TAI64.fromString(
    //     calculatedTimestamp.toString(),
    //     10
    //   ).toUnix(),
    // });
  } catch (error) {
    const [currentTimestamp, handleTimestamp, gracePeriod, why] =
      error.metadata.logs;
    // console.log(error.metadata);
    console.log({
      currentTimestamp: TAI64.fromString(
        currentTimestamp.toString(),
        10
      ).toUnix(),
      handleTimestamp: TAI64.fromString(
        handleTimestamp.toString(),
        10
      ).toUnix(),
      gracePeriod: TAI64.fromString(gracePeriod.toString(), 10).toUnix(),
      error: why,
    });
  }
}

// 1000000
// 8992413

main();
