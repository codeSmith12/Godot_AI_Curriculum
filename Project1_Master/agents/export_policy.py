"""Export this project's SB3 MLP policy for deterministic Godot playback."""
import json
from pathlib import Path
import numpy as np
import torch
from stable_baselines3 import PPO

root = Path(__file__).resolve().parent
model = PPO.load(root / 'flappy_bird_BestAgent.zip', device='cpu')
state = model.policy.state_dict()
layers = []
for name, activation in [('mlp_extractor.policy_net.0', 'tanh'), ('mlp_extractor.policy_net.2', 'tanh'), ('action_net', 'linear')]:
    layers.append({'weights': state[name + '.weight'].tolist(), 'bias': state[name + '.bias'].tolist(), 'activation': activation})
rng = np.random.default_rng(42)
fixtures = []
for obs in rng.uniform([0, -1, -0.075, -1], [1, 2, 1.1, 1], (32, 4)).astype(np.float32):
    tensor, _ = model.policy.obs_to_tensor({'obs': obs})
    with torch.no_grad():
        distribution = model.policy.get_distribution(tensor).distribution
        if isinstance(distribution, list):
            distribution = distribution[0]
        probabilities = distribution.probs[0].tolist()
    fixtures.append({'obs': obs.tolist(), 'probabilities': probabilities})
(root / 'best_policy.json').write_text(json.dumps({'layers': layers, 'fixtures': fixtures}))
print('Exported policy and 32 reference predictions')
