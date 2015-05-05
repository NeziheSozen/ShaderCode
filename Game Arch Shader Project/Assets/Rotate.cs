using UnityEngine;
using System.Collections;

public class Rotate : MonoBehaviour {
	Transform tf;
	// Use this for initialization
	void Start () {
		tf = GetComponent<Transform>();
	}
	
	// Update is called once per frame
	void Update () {
		
		tf.Rotate(Vector3.up,Time.deltaTime);
	}
}
