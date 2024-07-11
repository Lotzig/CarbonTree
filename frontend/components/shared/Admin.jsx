'use client';
import { useState, useEffect } from "react";
// Pour le layout
import { useToast } from "../ui/use-toast"; // Toast Shadcn/ui
import { Button } from "../ui/button"; // Bouton Shadcn/ui
import { Input } from "../ui/input"; // Input Shadcn/ui
import { RocketIcon } from "@radix-ui/react-icons" // Icône fusée
import { Alert, AlertDescription, AlertTitle, } from "@/components/ui/alert" // Alert Shadcn/ui

//Contract access
import { useReadContract, useAccount, useWriteContract, useWaitForTransactionReceipt } from "wagmi";
import { contractAddress, contractAbi } from "@/constants";

// Child components
import TokenTree from "./TokenTree";


const Admin = () => {

  const { toast } = useToast() // Toast Shadcn/ui
  //const [tokenTreeCollection, setTokenTreeCollection] = useState([]);
  const { data: hash, error, isPending: setIsPending, writeContract } = useWriteContract({
    mutation: {
      // onSuccess: () => {

      // },
      // onError: (error) => {

      // }
    }
  })

  const { data: FetchedTokenTreeCollection, error: FetchedTokenTreeCollectionError, isPending: FetchedTokenTreeCollectionIsPending, refetch } = useReadContract({
    address: contractAddress,
    abi: contractAbi,
    functionName: 'getAvailableTokenTrees',
    account: contractAddress
  })

  const { isLoading: isConfirming, isSuccess, error: errorConfirmation } = useWaitForTransactionReceipt({
    hash // le hash de la transaction, récupéré par le useWriteContract de Wagmi
  })

  const [species, setSpecies] = useState("");
  const [price, setPrice] = useState(0);
  const [plantingDate, setPlantingDate] = useState(0);
  const [location, setLocation] = useState("");
  const [locationOwnerName, setLocationOwnerName] = useState("");
  const [locationOwnerAddress, setLocationOwnerAddress] = useState("");
  
  useEffect(() => {
    // Si succès transaction
    if(isSuccess) {
      toast({
        title: "Transaction success",
        description: "Transaction succeeded",
        className: "bg-lime-200",
        isClosable: true,
      })
      refetch();  // on recharge les données du contrat
    }
        
    // Si erreur transaction
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

    // Si erreur avant transaction
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
  }, [isSuccess, errorConfirmation, error]) // succès ou erreur de la transaction (useWaitForTransactionReceipt de Wagmi)

  const addTokenTree = async() => {
    writeContract({
      address: contractAddress,
      abi: contractAbi,
      functionName: 'addTokenTree',
      args: [ species, price, plantingDate, location, locationOwnerName, locationOwnerAddress]
    })
  }

  return (
    <>
      <div>Admin</div>

      <h2 className="mt-6 mb-4 text-4xl">Available Token Trees</h2>
      <div className="flex flex-col w-full">
          {FetchedTokenTreeCollectionIsPending ? 
            ( <div>Loading...</div>
            ) : 
            ( FetchedTokenTreeCollection.length > 0 && FetchedTokenTreeCollection.map((tokenTree) => {
                return (
                  <TokenTree tokenTree={tokenTree} key={crypto.randomUUID()} />
                )  
              })
            )
          }  
      </div>

      <h2 className="mt-6 mb-4 text-4xl">Add a Token Tree</h2>

      <div className="w-1/4">
        <Input placeholder="Tree Species" onChange={(e) => setSpecies(e.target.value)} className="mb-2" />
        <Input placeholder="Price" onChange={(e) => setPrice(e.target.value)} className="mb-2"/>
        <Input placeholder="Planting Date" onChange={(e) => setPlantingDate(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location" onChange={(e) => setLocation(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location Owner Name" onChange={(e) => setLocationOwnerName(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location Owner Address" onChange={(e) => setLocationOwnerAddress(e.target.value)} className="mb-2"/>

        <Button variant="outline" disabled={setIsPending} onClick={addTokenTree}>{setIsPending ? ("Transaction pending..."):("Add Token Tree")}</Button>
      </div>    

    </>
  )
}

export default Admin