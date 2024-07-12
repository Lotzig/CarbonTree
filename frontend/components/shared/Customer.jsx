'use client';
import { ethers } from "ethers";
import { useState, useEffect } from "react";
// Pour le layout
import { useToast } from "../ui/use-toast"; // Toast Shadcn/ui
import { Button } from "../ui/button"; // Bouton Shadcn/ui
import { Input } from "../ui/input"; // Input Shadcn/ui

//Contract access
import { useReadContract, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { contractAddress, contractAbi } from "@/constants";

// Child components
import TokenTree from "./TokenTree";


const Customer = () => {

  const { toast } = useToast() // Toast Shadcn/ui
  const { data: hash, error, isPending: setIsPending, writeContract } = useWriteContract({
    mutation: {
      // onSuccess: () => {

      // },
      // onError: (error) => {

      // }
    }
  })

 
  // Get available token trees
  const { data: fetchedAvailableTokenTrees, error: fetchedAvailableTokenTreesError, isPending: fetchedAvailableTokenTreesIsPending
        , refetch: refetchAvailableTokenTrees } = useReadContract({
    address: contractAddress,
    abi: contractAbi,
    functionName: 'getAvailableTokenTrees',
  })

  //Get customer token trees
  const { data: fetchedCustomerTokenTrees, error: fetchedCustomerTokenTreesError, isPending: fetchedCustomerTokenTreesIsPending
        , refetch: refetchCustomerTokenTrees } = useReadContract({
    address: contractAddress,
    abi: contractAbi,
    functionName: 'getCustomerTokenTrees',
  })

  const { isLoading: isConfirming, isSuccess, error: errorConfirmation } = useWaitForTransactionReceipt({
    hash // le hash de la transaction, récupéré par le useWriteContract de Wagmi
  })

  const [tokenTreeKey, setTokenTreeKey] = useState(0);
  const [price, setPrice] = useState(0);
  
  useEffect(() => {
    // Si erreur chargement available tokens
    if(fetchedAvailableTokenTreesError) {
      toast({
          title: "Available tokens loading error",
          description: fetchTokenTreesError.shortMessage, 
          variant: "destructive",
          status: "error",
          duration: 4000,
          isClosable: true,
      });
    }

    if(fetchedCustomerTokenTreesError) {
      toast({
          title: "Customer tokens loading error",
          description: fetchedCustomerTokenTreesError.shortMessage, 
          variant: "destructive",
          status: "error",
          duration: 4000,
          isClosable: true,
      });
    }

    // Si succès buy
    if(isSuccess) {
      toast({
        title: "Transaction success",
        description: "Transaction succeeded",
        className: "bg-lime-200",
        isClosable: true,
      })
      refetchAvailableTokenTrees()
      refetchCustomerTokenTrees()
    }
   
    // Erreur transaction buy
    if(errorConfirmation) {
      toast({
          title: "Transaction error",
          description: errorConfirmation.shortMessage, 
          variant: "destructive",
          status: "error",
          duration: 4000,
          isClosable: true,
      });
    }

    // Si erreur avant transaction buy
    if(error) {
      toast({
          title: "Error",
          description: error.shortMessage,
          variant: "destructive", 
          status: "error",
          duration: 4000,
          isClosable: true,
      });
    }
  }, [fetchedAvailableTokenTreesError, fetchedCustomerTokenTreesError, isSuccess, errorConfirmation, error])

  const buy = async() => {
    writeContract({
      address: contractAddress,
      abi: contractAbi,
      functionName: 'buy',
      args: [ tokenTreeKey ],
      value: BigInt(price * 1E18)
    })
  }  



  return (
    <>
      <div className="text-4xl">YOUR ACCOUNT</div>

      <h2 className="mt-6 mb-4 text-3xl">Available Token Trees</h2>
      <div className="flex flex-col w-full">
          {fetchedAvailableTokenTreesIsPending ? 
            ( <div>Loading...</div>
            ) : 
            ( fetchedAvailableTokenTrees.length > 0 && fetchedAvailableTokenTrees.map((tokenTree) => {
                return (
                  <TokenTree tokenTree={tokenTree} key={crypto.randomUUID()} />
                )  
              })
            )
          }  
      </div>

      <h2 className="mt-6 mb-4 text-3xl">Buy a Token Tree</h2>

      <div className="flex">
        <Input placeholder="Token Tree Key" onChange={(e) => setTokenTreeKey(e.target.value)} className="mr-2 w-32" />
        <Input placeholder="Token Tree Price" onChange={(e) => setPrice(e.target.value)/*(BingInt(Number(e.target.value) * Number(1E18)))*/} className="mr-2 w-32" />
        <Button variant="outline" disabled={setIsPending} onClick={buy} className="text-lg">{setIsPending ? ("Transaction pending..."):("Buy Token Tree")}</Button>
      </div>    

      <h2 className="mt-6 mb-4 text-3xl">Your Token Trees</h2>
      <div className="flex flex-col w-full">
          {fetchedCustomerTokenTreesIsPending ? 
            ( <div>Loading...</div>
            ) : 
            ( fetchedCustomerTokenTrees?.length > 0 && fetchedCustomerTokenTrees?.map((tokenTree) => {
                return (
                  <TokenTree tokenTree={tokenTree} key={crypto.randomUUID()} />
                )  
              })
            )
          }  
      </div>
    </>
  )
}

export default Customer