/* Autogenerated file. Do not edit manually. */

/* tslint:disable */
/* eslint-disable */

/*
  Fuels version: 0.79.0
  Forc version: 0.49.3
  Fuel-Core version: 0.22.1
*/

import { Interface, Contract, ContractFactory } from "fuels";
import type { Provider, Account, AbstractAddress, BytesLike, DeployContractOptions, StorageSlot } from "fuels";
import type { ValidityContractAbi, ValidityContractAbiInterface } from "../ValidityContractAbi";

const _abi = {
  "types": [
    {
      "typeId": 0,
      "type": "(_, _, _, _, _, _)",
      "components": [
        {
          "name": "__tuple_element",
          "type": 6,
          "typeArguments": null
        },
        {
          "name": "__tuple_element",
          "type": 1,
          "typeArguments": null
        },
        {
          "name": "__tuple_element",
          "type": 1,
          "typeArguments": null
        },
        {
          "name": "__tuple_element",
          "type": 2,
          "typeArguments": null
        },
        {
          "name": "__tuple_element",
          "type": 8,
          "typeArguments": null
        },
        {
          "name": "__tuple_element",
          "type": 7,
          "typeArguments": null
        }
      ],
      "typeParameters": null
    },
    {
      "typeId": 1,
      "type": "b256",
      "components": null,
      "typeParameters": null
    },
    {
      "typeId": 2,
      "type": "bool",
      "components": null,
      "typeParameters": null
    },
    {
      "typeId": 3,
      "type": "raw untyped ptr",
      "components": null,
      "typeParameters": null
    },
    {
      "typeId": 4,
      "type": "struct Bytes",
      "components": [
        {
          "name": "buf",
          "type": 5,
          "typeArguments": null
        },
        {
          "name": "len",
          "type": 8,
          "typeArguments": null
        }
      ],
      "typeParameters": null
    },
    {
      "typeId": 5,
      "type": "struct RawBytes",
      "components": [
        {
          "name": "ptr",
          "type": 3,
          "typeArguments": null
        },
        {
          "name": "cap",
          "type": 8,
          "typeArguments": null
        }
      ],
      "typeParameters": null
    },
    {
      "typeId": 6,
      "type": "struct String",
      "components": [
        {
          "name": "bytes",
          "type": 4,
          "typeArguments": null
        }
      ],
      "typeParameters": null
    },
    {
      "typeId": 7,
      "type": "u16",
      "components": null,
      "typeParameters": null
    },
    {
      "typeId": 8,
      "type": "u64",
      "components": null,
      "typeParameters": null
    }
  ],
  "functions": [
    {
      "inputs": [],
      "name": "test_read_bytes",
      "output": {
        "name": "",
        "type": 0,
        "typeArguments": null
      },
      "attributes": null
    }
  ],
  "loggedTypes": [],
  "messagesTypes": [],
  "configurables": []
};

const _storageSlots: StorageSlot[] = [];

export class ValidityContractAbi__factory {
  static readonly abi = _abi;

  static readonly storageSlots = _storageSlots;

  static createInterface(): ValidityContractAbiInterface {
    return new Interface(_abi) as unknown as ValidityContractAbiInterface
  }

  static connect(
    id: string | AbstractAddress,
    accountOrProvider: Account | Provider
  ): ValidityContractAbi {
    return new Contract(id, _abi, accountOrProvider) as unknown as ValidityContractAbi
  }

  static async deployContract(
    bytecode: BytesLike,
    wallet: Account,
    options: DeployContractOptions = {}
  ): Promise<ValidityContractAbi> {
    const factory = new ContractFactory(bytecode, _abi, wallet);

    const { storageSlots } = ValidityContractAbi__factory;

    const contract = await factory.deployContract({
      storageSlots,
      ...options,
    });

    return contract as unknown as ValidityContractAbi;
  }
}
