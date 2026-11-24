import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from sklearn.model_selection import GroupShuffleSplit
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.compose import ColumnTransformer
import torch
import torch.nn as nn
from torch.utils.data import TensorDataset, DataLoader

# 1. CONNEXIÓ A MYSQL
# Substitueix usuari, contrasenya i host pels teus
engine = create_engine("mysql+pymysql://usuari:contrasenya@localhost/catchgene")
query = """ ... ENGANXA AQUÍ LA CONSULTA SQL DEL PAS 1 ... """
df = pd.read_sql(query, engine)

# 2. PREPARACIÓ DE FEATURES I TARGET
df['text_features'] = df['description_gene'] + " " + df['go_terms'].fillna('')
df['avg_gene_length'] = df['avg_gene_length'].fillna(df['avg_gene_length'].median())

# Target: Triem regressió amb log2(TPM + 1) per estabilitzar la xarxa
y = np.log2(df['expression_value'].values + 1.0).astype(np.float32)

# Divisió Train/Test agrupada per GEN (evita que la xarxa memoritzi gens)
gss = GroupShuffleSplit(n_splits=1, test_size=0.2, random_state=42)
train_idx, test_idx = next(gss.split(df, y, groups=df['pk_id_gene']))

# Pipeline de transformació de columnes
preprocessor = ColumnTransformer(transformers=[
    ('num', StandardScaler(), ['age', 'avg_gene_length']),
    ('cat', OneHotEncoder(handle_unknown='ignore'), ['species', 'tissue', 'sex', 'platform', 'exp_subtype']),
    ('txt', TfidfVectorizer(max_features=300, stop_words='english'), 'text_features')
])

X_train = preprocessor.fit_transform(df.iloc[train_idx]).toarray().astype(np.float32)
X_test = preprocessor.transform(df.iloc[test_idx]).toarray().astype(np.float32)
y_train, y_test = y[train_idx], y[test_idx]

# DataLoaders de PyTorch
train_loader = DataLoader(TensorDataset(torch.tensor(X_train), torch.tensor(y_train)), batch_size=64, shuffle=True)
test_loader = DataLoader(TensorDataset(torch.tensor(X_test), torch.tensor(y_test)), batch_size=64)

# 3. ARQUITECTURA DE LA XARXA NEURONAL (MLP)
class CatchGeneNet(nn.Module):
    def __init__(self, input_dim):
        super().__init__()
        self.network = nn.Sequential(
            nn.Linear(input_dim, 256),
            nn.BatchNorm1d(256),
            nn.ReLU(),
            nn.Dropout(0.3),
            
            nn.Linear(256, 128),
            nn.BatchNorm1d(128),
            nn.ReLU(),
            nn.Dropout(0.2),
            
            nn.Linear(128, 1) # Sortida contínua: log2(TPM + 1)
        )
        
    def forward(self, x):
        return self.network(x).squeeze(-1)

# 4. ENTRENAMENT
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = CatchGeneNet(X_train.shape[1]).to(device)
criterion = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3, weight_decay=1e-4)

for epoch in range(20):
    model.train()
    train_loss = 0.0
    for batch_x, batch_y in train_loader:
        batch_x, batch_y = batch_x.to(device), batch_y.to(device)
        optimizer.zero_grad()
        preds = model(batch_x)
        loss = criterion(preds, batch_y)
        loss.backward()
        optimizer.step()
        train_loss += loss.item() * len(batch_y)
        
    print(f"Època {epoch+1:02d} | Loss (MSE): {train_loss/len(X_train):.4f}")
