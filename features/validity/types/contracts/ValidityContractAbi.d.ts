/* Autogenerated file. Do not edit manually. */

/* tslint:disable */
/* eslint-disable */

/*
  Fuels version: 0.81.0
  Forc version: 0.49.3
  Fuel-Core version: 0.22.1
*/

import type {
  BigNumberish,
  BN,
  Bytes,
  BytesLike,
  Contract,
  DecodedValue,
  FunctionFragment,
  Interface,
  InvokeFunction,
  StdString,
} from 'fuels';

import type { Enum } from "./common";

export enum ValidyContractErrorInput { DomainAlreadyRegistered = 'DomainAlreadyRegistered', DomainNotRegistered = 'DomainNotRegistered', DomainExpired = 'DomainExpired', DomainUnavailable = 'DomainUnavailable' };
export enum ValidyContractErrorOutput { DomainAlreadyRegistered = 'DomainAlreadyRegistered', DomainNotRegistered = 'DomainNotRegistered', DomainExpired = 'DomainExpired', DomainUnavailable = 'DomainUnavailable' };

export type RawBytesInput = { ptr: BigNumberish, cap: BigNumberish };
export type RawBytesOutput = { ptr: BN, cap: BN };

interface ValidityContractAbiInterface extends Interface {
  functions: {
    register_domain: FunctionFragment;
    test_read_bytes: FunctionFragment;
    test_verify_grace_period: FunctionFragment;
    test_verify_grace_period_expired: FunctionFragment;
  };

  encodeFunctionData(functionFragment: 'register_domain', values: [StdString]): Uint8Array;
  encodeFunctionData(functionFragment: 'test_read_bytes', values: []): Uint8Array;
  encodeFunctionData(functionFragment: 'test_verify_grace_period', values: []): Uint8Array;
  encodeFunctionData(functionFragment: 'test_verify_grace_period_expired', values: []): Uint8Array;

  decodeFunctionData(functionFragment: 'register_domain', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'test_read_bytes', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'test_verify_grace_period', data: BytesLike): DecodedValue;
  decodeFunctionData(functionFragment: 'test_verify_grace_period_expired', data: BytesLike): DecodedValue;
}

export class ValidityContractAbi extends Contract {
  interface: ValidityContractAbiInterface;
  functions: {
    register_domain: InvokeFunction<[domain_name: StdString], void>;
    test_read_bytes: InvokeFunction<[], [string, string, boolean, BN, number]>;
    test_verify_grace_period: InvokeFunction<[], boolean>;
    test_verify_grace_period_expired: InvokeFunction<[], boolean>;
  };
}
