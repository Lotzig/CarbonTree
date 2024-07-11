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

  const [tokenTreeKeyUpdate, setTokenTreeKeyUpdate] = useState(0);
  const [tokenTreeKeyRemove, setTokenTreeKeyRemove] = useState(0);
  const [speciesAdd, setSpeciesAdd] = useState("");
  const [priceAdd, setPriceAdd] = useState(0);
  const [plantingDateAdd, setPlantingDateAdd] = useState(0);
  const [locationAdd, setLocationAdd] = useState("");
  const [locationOwnerNameAdd, setLocationOwnerNameAdd] = useState("");
  const [locationOwnerAddressAdd, setLocationOwnerAddressAdd] = useState("");

  const [speciesUpdate, setSpeciesUpdate] = useState("");
  const [priceUpdate, setPriceUpdate] = useState(0);
  const [plantingDateUpdate, setPlantingDateUpdate] = useState(0);
  const [locationUpdate, setLocationUpdate] = useState("");
  const [locationOwnerNameUpdate, setLocationOwnerNameUpdate] = useState("");
  const [locationOwnerAddressUpdate, setLocationOwnerAddressUpdate] = useState("");
  
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
      args: [ speciesAdd, priceAdd, plantingDateAdd, locationAdd, locationOwnerNameAdd, locationOwnerAddressAdd]
    })
  }

  const removeTokenTree = async() => {
    writeContract({
      address: contractAddress,
      abi: contractAbi,
      functionName: 'removeAvailableTokenTreeAdmin',
      args: [ tokenTreeKeyRemove]
    })
  }

  const updateTokenTree = async() => {
    writeContract({
      address: contractAddress,
      abi: contractAbi,
      functionName: 'updateTokenTree',
      args: [ tokenTreeKeyUpdate, speciesUpdate, priceUpdate, plantingDateUpdate, locationUpdate, locationOwnerNameUpdate, locationOwnerAddressUpdate]
    })
  }


  return (
    <>
      <div className="text-4xl">ADMINISTRATION</div>

      <h2 className="mt-6 mb-4 text-3xl">Available Token Trees</h2>
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

      <h2 className="mt-6 mb-4 text-3xl">Add a Token Tree</h2>

      <div className="w-1/4">
        <Input placeholder="Tree Species" onChange={(e) => setSpeciesAdd(e.target.value)} className="mb-2" />
        <Input placeholder="Price" onChange={(e) => setPriceAdd(e.target.value)} className="mb-2"/>
        <Input placeholder="Planting Date" onChange={(e) => setPlantingDateAdd(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location" onChange={(e) => setLocationAdd(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location Owner Name" onChange={(e) => setLocationOwnerNameAdd(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location Owner Address" onChange={(e) => setLocationOwnerAddressAdd(e.target.value)} className="mb-2"/>

        <Button variant="outline" disabled={setIsPending} onClick={addTokenTree} className="text-lg">{setIsPending ? ("Transaction pending..."):("Add Token Tree")}</Button>
      </div>    

      <h2 className="mt-6 mb-4 text-3xl">Remove a Token Tree</h2>
      
      <div className="flex">
        <Input placeholder="Token tree key" onChange={(e) => setTokenTreeKeyRemove(e.target.value)} className="mr-2 w-32" />
        <Button variant="outline" disabled={setIsPending} onClick={removeTokenTree} className="text-lg">{setIsPending ? ("Transaction pending..."):("Remove Token Tree")}</Button>
      </div>

      <h2 className="mt-6 mb-4 text-3xl">Update a Token Tree</h2>

      <div className="w-1/4">
        <Input placeholder="Key" onChange={(e) => setTokenTreeKeyUpdate(e.target.value)} className="mb-2" />
        <Input placeholder="Tree Species" onChange={(e) => setSpeciesUpdate(e.target.value)} className="mb-2" />
        <Input placeholder="Price" onChange={(e) => setPriceUpdate(e.target.value)} className="mb-2"/>
        <Input placeholder="Planting Date" onChange={(e) => setPlantingDateUpdate(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location" onChange={(e) => setLocationUpdate(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location Owner Name" onChange={(e) => setLocationOwnerNameUpdate(e.target.value)} className="mb-2"/>
        <Input placeholder="Tree Location Owner Address" onChange={(e) => setLocationOwnerAddressUpdate(e.target.value)} className="mb-2"/>

        <Button variant="outline" disabled={setIsPending} onClick={updateTokenTree} className="text-lg">{setIsPending ? ("Transaction pending..."):("Update Token Tree")}</Button>
      </div>    

    </>
  )
}

export default Admin