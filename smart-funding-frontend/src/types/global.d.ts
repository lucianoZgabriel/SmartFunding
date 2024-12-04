type EthereumRequestParams =
  | {
      chainId?: string;
    }
  | unknown[];

interface Window {
  ethereum?: {
    request: (args: {
      method: string;
      params?: EthereumRequestParams;
    }) => Promise<string[]>;
    on: (event: string, callback: (accounts: string[]) => void) => void;
    removeListener: (
      event: string,
      callback: (accounts: string[]) => void
    ) => void;
  };
}
