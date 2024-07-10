'use client';
import NotConnected from "@/components/shared/NotConnected";
import Admin from "@/components/shared/Admin";
import Customer from "@/components/shared/Customer";
import { useAccount, useReadContract } from "wagmi";
import { contractAddress, contractAbi } from "@/constants";

export default function Home() {

  const { isConnected, address: userAddress } = useAccount()
  
  const { data: owner } = useReadContract({
    address: contractAddress,
    abi: contractAbi,
    functionName: 'owner',
  })

  return (
     <>
        {
          isConnected ? (
            userAddress == owner ? (
              <Admin/>
            ) : (
              <Customer/> 
            )
          ) : (
            <NotConnected />
          )
        }
    </>
  );
}
