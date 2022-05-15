
%Load a pre-trained, dleep, convolutional network
net = mobilenetv2;
layers = net.Layers

%%Setup our training data
%Training dataset

%%Data Augmentation -  Use an augmented image datastore to automatically resize the training images
inputSize = net.Layers(1).InputSize;
 pixelRange = [-30 30];
 imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
     'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
 augtrainingImages = augmentedImageDatastore(inputSize(1:2),TrainTable, ...
     'DataAugmentation',imageAugmenter);

 %%Data Augmentation -  Use an augmented image datastore to automatically resize the test images
inputSize = net.Layers(1).InputSize;
 pixelRange = [-30 30];
 imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
     'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
 augtestImages = augmentedImageDatastore(inputSize(1:2),TestTable, ...
     'DataAugmentation',imageAugmenter);
%%Testing Data Augmentation - to automatically resize the validation/testing images without performing further data augmentation  
%augtestImages = augtestImages;

%Analyse the created network
%analyzeNetwork(alex)
layersTransfer = net.Layers(1:end-3);
%numClasses = numel(categories(trainingImages.Labels))
numClasses=1;

layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    regressionLayer];

%Set the network options
opts = trainingOptions('sgdm', ...
    'MiniBatchSize',10, ...
    'MaxEpochs',100, ...
    'InitialLearnRate',1e-4,...
    'ValidationData', augtestImages,...
    'ValidationFrequency',30,...
    'ExecutionEnvironment','cpu',...
    'Plots','training-progress');
    

%Train the Network
myNet = trainNetwork(augtrainingImages,lgraph_2,opts);

%% Measure Network Accuracy
 YPredicted = predict(myNet,augtestImages);

%%Evaluate Performance
 predictionError = TestTable.Labels1(:,1)- YPredicted;
 threshold = 0.5;
 numCorrect = sum(abs(predictionError) < threshold);
 numValidationImages = numel(TestTable.Labels1(:,1));

 accuracy = numCorrect/numValidationImages
 squares = predictionError.^2;
 mse = mean(squares)
 rmse = sqrt(mean(squares))
 mae = mean(abs(predictionError))
 mre = mean(abs(predictionError)./TestTable.Labels1(:,1))
 mape = mean((abs(predictionError)./TestTable.Labels1(:,1))*100)

%%Visualize Predictions
  figure
  scatter(YPredicted,TestTable.Labels1(:,1),'+')
  xlabel("Predicted Value (v)",'FontWeight','bold')
  ylabel("True Value (v)",'FontWeight','bold')

 %plot the linear regression model.
 hold on
 [p,S]=polyfit(YPredicted, TestTable.Labels1(:,1), 1);
 [y_fit,delta] = polyval(p,TestTable.Labels1(:,1),S);
 plot(TestTable.Labels1(:,1),y_fit,'r-')

 mdl = fitlm(YPredicted, TestTable.Labels1(:,1))